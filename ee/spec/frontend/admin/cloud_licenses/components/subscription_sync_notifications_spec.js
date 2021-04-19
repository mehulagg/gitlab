import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import SubscriptionSyncNotifications, {
  notificationType,
} from 'ee/pages/admin/cloud_licenses/components/subscription_sync_notifications.vue';
import { userNotifications } from 'ee/pages/admin/cloud_licenses/constants';
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
        propsData: props,
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
    it('displays an alert with success message', () => {
      createComponent({
        props: { notification: notificationType.SYNC_SUCCESS },
      });

      expect(findSuccessAlert().text()).toBe(userNotifications.manualSyncSuccessfulText);
    });
  });

  describe('sync failure notification', () => {
    beforeEach(() => {
      createComponent({
        props: { notification: notificationType.SYNC_FAILURE },
        stubs: { GlSprintf },
      });
    });

    it('displays an alert with a failure message', () => {
      expect(findFailureAlert().text()).toContain('There is a connectivity Issue');
    });

    it('displays a link', () => {
      expect(findLink().attributes('href')).toBe(connectivityHelpURL);
    });
  });
});
