import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import SubscriptionSyncNotifications, {
  SUCCESS_ALERT_DISMISSED_EVENT,
} from 'ee/pages/admin/cloud_licenses/components/subscription_sync_notifications.vue';
import {
  connectivityIssue,
  manualSyncSuccessfulTitle,
  subscriptionSyncStatus,
} from 'ee/pages/admin/cloud_licenses/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('Subscription Sync Notifications', () => {
  let wrapper;

  const connectivityHelpURL = 'connectivity/help/url';

  const finAllAlerts = () => wrapper.findAllComponents(GlAlert);
  const findFailureAlert = () => wrapper.findByTestId('sync-failure-alert');
  const findSuccessAlert = () => wrapper.findByTestId('sync-success-alert');
  const findLink = () => wrapper.findComponent(GlLink);

  const createComponent = ({ props, stubs } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(SubscriptionSyncNotifications, {
        propsData: {
          syncStatus: '',
          ...props,
        },
        provide: { connectivityHelpURL },
        stubs,
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('idle state', () => {
    it('displays no alert', () => {
      createComponent();

      expect(finAllAlerts()).toHaveLength(0);
    });
  });

  describe('sync success notification', () => {
    beforeEach(() => {
      createComponent({
        props: { syncStatus: subscriptionSyncStatus.SYNC_SUCCESS },
      });
    });

    it('displays an alert with success message', () => {
      expect(findSuccessAlert().props('title')).toBe(manualSyncSuccessfulTitle);
    });

    it('emits an event when dismissed', () => {
      findSuccessAlert().vm.$emit('dismiss');

      expect(wrapper.emitted(SUCCESS_ALERT_DISMISSED_EVENT)).toEqual([[]]);
    });
  });

  describe('sync failure notification', () => {
    beforeEach(() => {
      createComponent({
        props: { syncStatus: subscriptionSyncStatus.SYNC_FAILURE },
        stubs: { GlSprintf },
      });
    });

    it('displays an alert with a failure title', () => {
      expect(findFailureAlert().props('title')).toBe(connectivityIssue);
    });

    it('displays an alert with a failure message', () => {
      expect(findFailureAlert().text()).toBe(
        'You can no longer sync your subscription details with GitLab. Get help for the most common connectivity issues by troubleshooting the activation code.',
      );
    });

    it('displays a link', () => {
      expect(findLink().attributes('href')).toBe(connectivityHelpURL);
    });
  });
});
