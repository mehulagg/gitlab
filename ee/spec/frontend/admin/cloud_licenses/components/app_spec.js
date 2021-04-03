import { shallowMount } from '@vue/test-utils';
import CloudLicenseApp from 'ee/pages/admin/cloud_licenses/components/app.vue';
import CloudLicenseSubscriptionActivationForm from 'ee/pages/admin/cloud_licenses/components/subscription_activation_form.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('CloudLicenseApp', () => {
  let wrapper;

  const findActivateSubscriptionForm = () =>
    wrapper.findComponent(CloudLicenseSubscriptionActivationForm);

  const createComponent = (props = {}) => {
    wrapper = extendedWrapper(
      shallowMount(CloudLicenseApp, {
        propsData: {
          ...props,
        },
        provide: {
          planName: 'Core',
        },
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Subscription Activation Form', () => {
    beforeEach(() => createComponent());

    it('presents a form', () => {
      expect(findActivateSubscriptionForm().exists()).toBe(true);
    });

    it('presents a main title with the plan name', () => {
      expect(wrapper.text()).toContain('Core plan');
    });
  });
});
