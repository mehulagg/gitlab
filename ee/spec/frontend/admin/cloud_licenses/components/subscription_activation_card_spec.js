import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import SubscriptionActivationCard, {
  subscriptionActivationHelpLink,
  troubleshootingHelpLink,
} from 'ee/pages/admin/cloud_licenses/components/subscription_activation_card.vue';
import SubscriptionActivationForm, {
  SUBSCRIPTION_ACTIVATION_FAILURE_EVENT,
} from 'ee/pages/admin/cloud_licenses/components/subscription_activation_form.vue';
import { CONNECTIVITY_ERROR } from 'ee/pages/admin/cloud_licenses/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('CloudLicenseApp', () => {
  let wrapper;

  const findConnectivityErrorAlert = () => wrapper.findComponent(GlAlert);
  const findSubscriptionActivationForm = () => wrapper.findComponent(SubscriptionActivationForm);

  const createComponent = ({ props = {}, stubs = {} } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(SubscriptionActivationCard, {
        propsData: {
          ...props,
        },
        stubs,
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
    expect(findConnectivityErrorAlert().exists()).toBe(false);
  });

  describe('when the forms emits a connectivity error', () => {
    beforeEach(() => {
      createComponent({ stubs: { GlSprintf } });
      findSubscriptionActivationForm().vm.$emit(
        SUBSCRIPTION_ACTIVATION_FAILURE_EVENT,
        CONNECTIVITY_ERROR,
      );
    });

    it('shows an alert component', () => {
      expect(findConnectivityErrorAlert().exists()).toBe(true);
    });

    it('shows some help links', () => {
      const alert = findConnectivityErrorAlert();

      expect(alert.findAll(GlLink).at(0).attributes('href')).toBe(subscriptionActivationHelpLink);
      expect(alert.findAll(GlLink).at(1).attributes('href')).toBe(troubleshootingHelpLink);
    });
  });
});
