import { shallowMount } from '@vue/test-utils';
import { GlLoadingIcon } from '@gitlab/ui';
import MockAxiosAdapter from 'axios-mock-adapter';
import waitForPromises from 'helpers/wait_for_promises';
import SharedRunnersForm from '~/group_settings/components/shared_runners_form.vue';
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';

const TEST_UPDATE_PATH = '/test/update';
const DISABLED_PAYLOAD = { shared_runners_setting: 'disabled_and_unoverridable' };
const ENABLED_PAYLOAD = { shared_runners_setting: 'enabled' };
const OVERRIDE_PAYLOAD = { shared_runners_setting: 'disabled_with_override' };

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
  const findEnabledToggle = () => wrapper.find('[data-testid="enable-runners-toggle"]');
  const findOverrideToggle = () => wrapper.find('[data-testid="override-runners-toggle"]');
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
      expect(findOverrideToggle().exists()).toBe(false);
    });
  });

  describe('enable toggle', () => {
    beforeEach(() => {
      createComponent();
    });

    it('enabling the toggle sends correct payload', async () => {
      findEnabledToggle().vm.$emit('change', true);

      await waitForPromises();

      expect(getRequestPayload()).toEqual(ENABLED_PAYLOAD);
      expect(findOverrideToggle().exists()).toBe(false);
    });

    it('disabling the toggle sends correct payload', async () => {
      findEnabledToggle().vm.$emit('change', false);

      await waitForPromises();

      expect(getRequestPayload()).toEqual(DISABLED_PAYLOAD);
      expect(findOverrideToggle().exists()).toBe(true);
    });
  });

  describe('override toggle', () => {
    beforeEach(() => {
      createComponent({ initEnabled: false });
    });

    it('enabling the override toggle sends correct payload', async () => {
      findOverrideToggle().vm.$emit('change', true);

      await waitForPromises();

      expect(getRequestPayload()).toEqual(OVERRIDE_PAYLOAD);
    });

    it('disabling the override toggle sends correct payload', async () => {
      findOverrideToggle().vm.$emit('change', false);

      await waitForPromises();

      expect(getRequestPayload()).toEqual(DISABLED_PAYLOAD);
    });
  });

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
