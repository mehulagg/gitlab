import { shallowMount } from '@vue/test-utils';
import SubscriptionActivationCard from 'ee/pages/admin/cloud_licenses/components/subscription_activation_card.vue';
import SubscriptionActivationErrors from 'ee/pages/admin/cloud_licenses/components/subscription_activation_errors.vue';
import SubscriptionActivationForm, {
  SUBSCRIPTION_ACTIVATION_FAILURE_EVENT,
} from 'ee/pages/admin/cloud_licenses/components/subscription_activation_form.vue';
import { CONNECTIVITY_ERROR } from 'ee/pages/admin/cloud_licenses/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('CloudLicenseApp', () => {
  let wrapper;

  const findSubscriptionActivationForm = () => wrapper.findComponent(SubscriptionActivationForm);
  const findSubscriptionActivationErrors = () =>
    wrapper.findComponent(SubscriptionActivationErrors);

  const createComponent = ({ props = {} } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(SubscriptionActivationCard, {
        propsData: {
          ...props,
        },
      }),
    );
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('shows a form', () => {
    expect(findSubscriptionActivationForm().exists()).toBe(true);
  });

  it('does not show any alert', () => {
    expect(findSubscriptionActivationErrors().exists()).toBe(false);
  });

  describe('when the forms emits a connectivity error', () => {
    beforeEach(() => {
      createComponent();
      findSubscriptionActivationForm().vm.$emit(
        SUBSCRIPTION_ACTIVATION_FAILURE_EVENT,
        CONNECTIVITY_ERROR,
      );
    });

    it('shows an alert component', () => {
      expect(findSubscriptionActivationErrors().exists()).toBe(true);
    });

    it('passes the correct error to the component', () => {
      expect(findSubscriptionActivationErrors().props('error')).toBe(CONNECTIVITY_ERROR);
    });
  });
});
