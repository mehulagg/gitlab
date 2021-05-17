import { GlLink, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import {
  subscriptionActivationHelpLink,
  troubleshootingHelpLink,
} from 'ee/pages/admin/cloud_licenses/components/subscription_activation_card.vue';
import SubscriptionActivationErrors from 'ee/pages/admin/cloud_licenses/components/subscription_activation_errors.vue';
import {
  CONNECTIVITY_ERROR,
  connectivityIssue,
  generalActivationError,
} from 'ee/pages/admin/cloud_licenses/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('SubscriptionActivationErrors', () => {
  let wrapper;

  const findConnectivityErrorAlert = () => wrapper.findByTestId('connectivity-error-alert');
  const findGeneralErrorAlert = () => wrapper.findByTestId('general-error-alert');

  const createComponent = ({ props = {} } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(SubscriptionActivationErrors, {
        propsData: {
          ...props,
        },
        stubs: { GlSprintf },
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('connectivity error', () => {
    beforeEach(() => {
      createComponent({ props: { error: CONNECTIVITY_ERROR } });
    });

    it('shows the alert', () => {
      expect(findConnectivityErrorAlert().props('title')).toBe(connectivityIssue);
    });

    it('shows some help links', () => {
      const alert = findConnectivityErrorAlert();

      expect(alert.findAll(GlLink).at(0).props('href')).toBe(subscriptionActivationHelpLink);
      expect(alert.findAll(GlLink).at(1).props('href')).toBe(troubleshootingHelpLink);
    });

    it('does not show other alerts', () => {
      expect(findGeneralErrorAlert().exists()).toBe(false);
    });
  });

  describe('general error', () => {
    beforeEach(() => {
      createComponent({ props: { error: 'A fake error' } });
    });

    it('shows a general error alert', () => {
      expect(findGeneralErrorAlert().props('title')).toBe(generalActivationError);
    });

    it('shows a a text to help the user', () => {
      expect(findGeneralErrorAlert().text()).toBe('Learn how to activate your subscription.');
    });

    it('does not show the connectivity alert', () => {
      expect(findConnectivityErrorAlert().exists()).toBe(false);
    });
  });
});
