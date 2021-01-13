import Vuex from 'vuex';
import { createLocalVue, shallowMount, mount } from '@vue/test-utils';
import { GlLink, GlModal } from '@gitlab/ui';
import merge from 'lodash/merge';
import waitForPromises from 'helpers/wait_for_promises';
import createStore from 'ee/issue_show/components/incidents/store';
import MetricsImage from 'ee/issue_show/components/incidents/metrics_image.vue';

const defaultProps = {
  id: 1,
  filePath: 'test_file_path',
  filename: 'test_file_name',
};

const mockEvent = { preventDefault: jest.fn() };

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Metrics upload item', () => {
  let wrapper;
  let store;

  const mountComponent = (options = {}, mountMethod = mount) => {
    store = createStore();

    wrapper = mountMethod(
      MetricsImage,
      merge(
        {
          localVue,
          store,
          propsData: {
            ...defaultProps,
          },
          provide: { canUpdate: true },
        },
        options,
      ),
    );
  };

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  const findImageLink = () => wrapper.find(GlLink);
  const findCollapseButton = () => wrapper.find('[data-testid="collapse-button"]');
  const findMetricImageBody = () => wrapper.find('[data-testid="metric-image-body"]');
  const findModal = () => wrapper.find(GlModal);
  const findDeleteButton = () => wrapper.find('[data-testid="delete-button"]');

  const submitModal = () => findModal().vm.$emit('primary', mockEvent);
  const deleteImage = () => findDeleteButton().vm.$emit('click');

  it('render the metrics image component', () => {
    mountComponent({}, shallowMount);

    expect(wrapper.element).toMatchSnapshot();
  });

  it('shows a link with the correct url', () => {
    const testUrl = 'test_url';
    mountComponent({ propsData: { url: testUrl } });

    expect(findImageLink().attributes('href')).toBe(testUrl);
    expect(findImageLink().text()).toBe(defaultProps.filename);
  });

  describe('expand and collapse', () => {
    beforeEach(() => {
      mountComponent();
    });

    it('the card is expanded by default', () => {
      expect(findMetricImageBody().isVisible()).toBe(true);
    });

    it('the card is collapsed when clicked', async () => {
      findCollapseButton().trigger('click');

      await waitForPromises();

      expect(findMetricImageBody().isVisible()).toBe(false);
    });
  });

  describe('delete functionality', () => {
    beforeEach(() => {
      mountComponent();
    });

    it('should open the modal when clicked', async () => {
      deleteImage();

      await waitForPromises();

      expect(findModal().attributes('visible')).toBe('true');
    });

    it('should close the modal when cancelled', async () => {
      mountComponent(
        {
          data() {
            return { modalVisible: true };
          },
        },
        shallowMount,
      );

      await waitForPromises();

      findModal().vm.$emit('hidden');

      await waitForPromises();

      expect(findModal().attributes('visible')).toBeFalsy();
    });

    it('should delete the image when selected', async () => {
      mountComponent(
        {
          data() {
            return { modalVisible: true };
          },
        },
        shallowMount,
      );

      const dispatchSpy = jest.spyOn(store, 'dispatch').mockImplementation(jest.fn());

      await waitForPromises();

      submitModal();

      await waitForPromises();

      expect(dispatchSpy).toHaveBeenCalledWith('deleteImage', defaultProps.id);
    });
  });

  // TODO: Add spec for when `canUpdate` is `false`
});
