import { GlToggle } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import CcValidationRequiredAlert from 'ee_component/billings/components/cc_validation_required_alert.vue';
import { TEST_HOST } from 'helpers/test_constants';
import waitForPromises from 'helpers/wait_for_promises';
import SharedRunnersToggleComponent from '~/projects/settings/components/shared_runners_toggle.vue';

const TEST_UPDATE_PATH = '/test/update_shared_runners';

describe('projects/settings/components/shared_runners', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(SharedRunnersToggleComponent, {
      propsData: {
        isEnabled: false,
        isDisabledAndUnoverridable: false,
        isLoading: false,
        updatePath: TEST_UPDATE_PATH,
        isCreditCardValidationRequired: false,
        ...props,
      },
    });
  };

  const findSharedRunnersToggle = () => wrapper.find(GlToggle);
  const findCcValidationRequiredAlert = () => wrapper.findComponent(CcValidationRequiredAlert);
  const getToggleValue = () => findSharedRunnersToggle().props('value');
  const isToggleDisabled = () => findSharedRunnersToggle().props('disabled');

  afterEach(() => {
    wrapper.destroy();
  });

  describe('with credit card validation required and shared runners DISABLED', () => {
    beforeEach(() => {
      window.gon = {
        subscriptions_url: TEST_HOST,
        payment_form_url: TEST_HOST,
      };

      createComponent({
        isCreditCardValidationRequired: true,
        isEnabled: false,
      });
    });

    it('toggle should not be visible', () => {
      expect(findSharedRunnersToggle().exists()).toBe(false);
    });

    it('credit card validation component should exist', () => {
      expect(findCcValidationRequiredAlert().exists()).toBe(true);
      expect(findCcValidationRequiredAlert().text()).toBe(
        SharedRunnersToggleComponent.i18n.REQUIRES_VALIDATION_TEXT,
      );
    });

    describe('when credit card is validated', () => {
      it('should show the toggle button', async () => {
        findCcValidationRequiredAlert().vm.$emit('verifiedCreditCard');
        await waitForPromises();

        expect(findSharedRunnersToggle().exists()).toBe(true);
        expect(getToggleValue()).toBe(false);
        expect(isToggleDisabled()).toBe(false);
      });
    });
  });
});
