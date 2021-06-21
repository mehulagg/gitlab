import { GlLoadingIcon } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import RelatedFeatureFlags from 'ee/related_feature_flags/components/related_feature_flags.vue';
import { TEST_HOST } from 'helpers/test_constants';
import { trimText } from 'helpers/text_helper';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';

jest.mock('~/flash');

const ENDPOINT = `${TEST_HOST}/endpoint`;

const DEFAULT_PROVIDE = {
  endpoint: ENDPOINT,
};

const MOCK_DATA = [
  {
    id: 5,
    name: 'foo',
    iid: 2,
    active: true,
    path: '/gitlab-org/gitlab-test/-/feature_flags/2',
    reference: '[feature_flag:2]',
    link_type: 'relates_to',
  },
  {
    id: 2,
    name: 'bar',
    iid: 1,
    active: false,
    path: '/h5bp/html5-boilerplate/-/feature_flags/1',
    reference: '[feature_flag:h5bp/html5-boilerplate/1]',
    link_type: 'relates_to',
  },
];

describe('ee/related_feature_flags/components/related_feature_flags.vue', () => {
  let mock;
  let wrapper;

  const createWrapper = (provide = {}) => {
    wrapper = extendedWrapper(
      mount(RelatedFeatureFlags, {
        provide: {
          ...DEFAULT_PROVIDE,
          ...provide,
        },
      }),
    );
  };

  afterEach(() => {
    mock.restore();

    wrapper?.destroy?.();

    wrapper = null;
  });

  beforeEach(() => {
    mock = new MockAdapter(axios);
  });

  describe('with endpoint', () => {
    it('displays a loading icon while feature flags load', () => {
      mock.onGet(ENDPOINT).reply(() => new Promise(() => {}));
      createWrapper();
      expect(wrapper.findComponent(GlLoadingIcon).exists()).toBe(true);
    });

    it('displays nothing if there are no feature flags loaded', async () => {
      mock.onGet(ENDPOINT).reply(200, []);
      createWrapper();
      await waitForPromises();
      await wrapper.vm.$nextTick();

      expect(wrapper.find('#related-feature-flags').exists()).toBe(false);
    });

    it('displays nothing if the request fails', async () => {
      mock.onGet(ENDPOINT).reply(500);
      createWrapper();
      await waitForPromises();
      await wrapper.vm.$nextTick();

      expect(createFlash).toHaveBeenCalledWith(
        expect.objectContaining({
          message: 'There was an error loading related feature flags',
        }),
      );
      expect(wrapper.find('#related-feature-flags').exists()).toBe(false);
    });

    describe('with loaded feature flags', () => {
      beforeEach(async () => {
        mock.onGet(ENDPOINT).reply(200, MOCK_DATA);
        createWrapper();
        await waitForPromises();
        await wrapper.vm.$nextTick();
      });

      it('displays the number of referenced feature flags', () => {
        const header = wrapper.findByTestId('referenced-feature-flags-header');
        expect(trimText(header.text())).toBe(`Related feature flags ${MOCK_DATA.length}`);
      });

      it.each(MOCK_DATA.map((data, index) => [data.name, data, index]))(
        'displays information for feature flag %s',
        (_, flag, index) => {
          const flagRow = extendedWrapper(
            wrapper.findAllByTestId('feature-flag-details').at(index),
          );

          const icon = flagRow.findByTestId('feature-flag-details-icon');
          expect(icon.props('name')).toBe(flag.active ? 'feature-flag' : 'feature-flag-disabled');
          expect(icon.attributes('title')).toBe(flag.active ? 'Active' : 'Inactive');

          const link = flagRow.findByTestId('feature-flag-details-link');
          expect(link.text()).toBe(flag.name);
          expect(link.props('href')).toBe(flag.link);
          expect(link.attributes('title')).toBe(flag.name);

          const reference = flagRow.findByTestId('feature-flag-details-reference');
          expect(reference.text()).toBe(flag.reference);
          expect(reference.attributes('title')).toBe(flag.reference);
        },
      );
    });
  });

  describe('without endoint', () => {
    it('renders nothing', async () => {
      createWrapper({ endpoint: '' });
      await wrapper.vm.$nextTick();

      expect(wrapper.find('#related-feature-flags').exists()).toBe(false);
    });
  });
});
