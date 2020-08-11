import { shallowMount } from '@vue/test-utils';
import SharedRunnersForm from '~/group_settings/components/shared_runners_form.vue';
import { GlLoadingIcon, GlToggle } from '@gitlab/ui';
import MockAxiosAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import waitForPromises from 'helpers/wait_for_promises';
import createFlash from '~/flash';

const TEST_UPDATE_PATH = '/test/update';

jest.mock('~/flash');

describe('group_settings/components/shared_runners_form', () => {
  let wrapper;
  let mock;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(SharedRunnersForm, {
      propsData: {
        updatePath: TEST_UPDATE_PATH,
        initEnabled: true,
        initAllowOverride: true,
        parentAllowOverride: true,
        ...props,
      },
    });
  };

  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findToggle = label =>
    wrapper.findAll(GlToggle).wrappers.find(x => x.props('label') === label);
  const findEnabledToggle = () => findToggle('Enable Shared Runners for this group');
  const findOverrideToggle = () =>
    findToggle('Allow projects/subgroups to override the group setting');
  const changeToggle = toggle => toggle.vm.$emit('change', !toggle.props('value'));
  const getRequestPayload = () => JSON.parse(mock.history.post[0].data);
  const isLoadingIconVisible = () => findLoadingIcon().element.style.display !== 'none';

  beforeEach(() => {
    mock = new MockAxiosAdapter(axios);

    mock.onPost(TEST_UPDATE_PATH).reply(200);
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;

    mock.restore();
  });

  describe('with default', () => {
    beforeEach(() => {
      createComponent();
    });

    it('loading icon does not exist', () => {
      expect(isLoadingIconVisible()).toBe(false);
    });

    it('enabled toggle exists', () => {
      expect(findEnabledToggle().exists()).toBe(true);
    });

    it('override toggle does not exist', () => {
      expect(findOverrideToggle()).toBeUndefined();
    });
  });

  describe.each`
    props                     | toggleButtonFn        | hasOverrideToggle | expectedPayload
    ${{}}                     | ${findEnabledToggle}  | ${true}           | ${{ shared_runners_enabled: false, allow_descendants_override_disabled_shared_runners: true }}
    ${{ initEnabled: false }} | ${findEnabledToggle}  | ${false}          | ${{ shared_runners_enabled: true }}
    ${{ initEnabled: false }} | ${findOverrideToggle} | ${false}          | ${{ shared_runners_enabled: false, allow_descendants_override_disabled_shared_runners: false }}
  `(
    'with $toggleButtonFn toggle change $props',
    ({ props, toggleButtonFn, hasOverrideToggle, expectedPayload }) => {
      beforeEach(() => {
        mock.onPost(TEST_UPDATE_PATH).reply(() => new Promise(() => {}));

        createComponent(props);
        changeToggle(toggleButtonFn());
      });

      if (hasOverrideToggle) {
        it('override toggle does exist', () => {
          expect(findOverrideToggle().exists()).toBe(true);
        });
      }

      it('calls endpoint with correct payload', () => {
        expect(getRequestPayload()).toEqual(expectedPayload);
      });

      it('toggles are disabled', () => {
        expect(findEnabledToggle().props('disabled')).toBe(true);

        if (hasOverrideToggle) {
          expect(findOverrideToggle().props('disabled')).toBe(true);
        }
      });

      it('shows loading icon', () => {
        expect(isLoadingIconVisible()).toBe(true);
      });
    },
  );

  describe('with response', () => {
    beforeEach(async () => {
      createComponent();
      changeToggle(findEnabledToggle());

      await waitForPromises();
    });

    it('toggles are not disabled', () => {
      expect(findEnabledToggle().props('disabled')).toBe(false);
      expect(findOverrideToggle().props('disabled')).toBe(false);
    });
  });

  describe.each`
    errorObj                        | message
    ${{}}                           | ${'An error occurred while updating configuration. Refresh the page and try again.'}
    ${{ error: 'Undefined error' }} | ${'Undefined error Refresh the page and try again.'}
  `('with error $errorObj', ({ errorObj, message }) => {
    beforeEach(async () => {
      mock.onPost(TEST_UPDATE_PATH).reply(500, errorObj);

      createComponent();
      changeToggle(findEnabledToggle());

      await waitForPromises();
    });

    it('createFlash should have been called', () => {
      expect(createFlash).toHaveBeenCalledWith(message);
    });
  });
});
