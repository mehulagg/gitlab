import { GlCard } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import AxiosMockAdapter from 'axios-mock-adapter';
import { nextTick } from 'vue';
import SubscriptionBreakdown, {
  licensedToFields,
  subscriptionDetailsFields,
} from 'ee/pages/admin/cloud_licenses/components/subscription_breakdown.vue';
import SubscriptionDetailsCard from 'ee/pages/admin/cloud_licenses/components/subscription_details_card.vue';
import SubscriptionDetailsHistory from 'ee/pages/admin/cloud_licenses/components/subscription_details_history.vue';
import SubscriptionDetailsUserInfo from 'ee/pages/admin/cloud_licenses/components/subscription_details_user_info.vue';
import SubscriptionSyncNotifications, {
  SUCCESS_ALERT_DISMISSED_EVENT,
} from 'ee/pages/admin/cloud_licenses/components/subscription_sync_notifications.vue';
import {
  licensedToHeaderText,
  notificationType,
  subscriptionDetailsHeaderText,
} from 'ee/pages/admin/cloud_licenses/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import axios from '~/lib/utils/axios_utils';
import { license, subscriptionHistory } from '../mock_data';

describe('Subscription Breakdown', () => {
  let axiosMock;
  let wrapper;

  const [, legacyLicense] = subscriptionHistory;
  const connectivityHelpURL = 'connectivity/help/url';
  const subscriptionSyncPath = '/sync/path/';

  const findDetailsCards = () => wrapper.findAllComponents(SubscriptionDetailsCard);
  const findDetailsCardFooter = () => wrapper.find('.gl-card-footer');
  const findDetailsHistory = () => wrapper.findComponent(SubscriptionDetailsHistory);
  const findDetailsUserInfo = () => wrapper.findComponent(SubscriptionDetailsUserInfo);
  const findSubscriptionSyncAction = () => wrapper.findByTestId('subscription-sync-action');
  const findSubscriptionSyncNotifications = () =>
    wrapper.findComponent(SubscriptionSyncNotifications);

  const createComponent = ({ props, stubs } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(SubscriptionBreakdown, {
        provide: {
          connectivityHelpURL,
          subscriptionSyncPath,
        },
        propsData: {
          subscription: license.ULTIMATE,
          subscriptionList: subscriptionHistory,
          ...props,
        },
        stubs,
      }),
    );
  };

  beforeEach(() => {
    axiosMock = new AxiosMockAdapter(axios);
  });

  afterEach(() => {
    axiosMock.restore();
    wrapper.destroy();
  });

  describe('with subscription data', () => {
    beforeEach(() => {
      createComponent();
    });

    it('shows 2 details card', () => {
      expect(findDetailsCards()).toHaveLength(2);
    });

    it('provides the correct props to the cards', () => {
      const props = findDetailsCards().wrappers.map((w) => w.props());

      expect(props).toEqual([
        {
          detailsFields: subscriptionDetailsFields,
          headerText: subscriptionDetailsHeaderText,
          subscription: license.ULTIMATE,
        },
        {
          detailsFields: licensedToFields,
          headerText: licensedToHeaderText,
          subscription: license.ULTIMATE,
        },
      ]);
    });

    it('shows the user info', () => {
      expect(findDetailsUserInfo().exists()).toBe(true);
    });

    it('provides the correct props to the user info component', () => {
      expect(findDetailsUserInfo().props('subscription')).toBe(license.ULTIMATE);
    });

    it('does not show notifications', () => {
      expect(findSubscriptionSyncNotifications().exists()).toBe(false);
    });

    it('shows the subscription details footer', () => {
      createComponent({ stubs: { GlCard, SubscriptionDetailsCard } });

      expect(findDetailsCardFooter().exists()).toBe(true);
    });

    it('shows a button to sync the subscription', () => {
      createComponent({ stubs: { GlCard, SubscriptionDetailsCard } });

      expect(findSubscriptionSyncAction().exists()).toBe(true);
    });

    it.todo('shows a button to manage the subscription');

    describe('with a legacy license', () => {
      beforeEach(() => {
        createComponent({
          props: { subscription: legacyLicense },
          stubs: { GlCard, SubscriptionDetailsCard },
        });
      });

      it('does not show a button to sync the subscription', () => {
        expect(findSubscriptionSyncAction().exists()).toBe(false);
      });

      it('does not show the subscription details footer', () => {
        expect(findDetailsCardFooter().exists()).toBe(false);
      });

      it('does not show the sync subscription notifications', () => {
        expect(findSubscriptionSyncNotifications().exists()).toBe(false);
      });
    });

    describe('sync a subscription success', () => {
      beforeEach(() => {
        axiosMock.onPost(subscriptionSyncPath).reply(200, { success: true });
        createComponent({ stubs: { GlCard, SubscriptionDetailsCard } });
        findSubscriptionSyncAction().vm.$emit('click');
        return waitForPromises();
      });

      it('shows a success notification', () => {
        expect(findSubscriptionSyncNotifications().props('notification')).toBe(
          notificationType.SYNC_SUCCESS,
        );
      });

      it('dismisses the success notification', async () => {
        findSubscriptionSyncNotifications().vm.$emit(SUCCESS_ALERT_DISMISSED_EVENT);
        await nextTick();

        expect(findSubscriptionSyncNotifications().exists()).toBe(false);
      });
    });

    describe('sync a subscription failure', () => {
      beforeEach(() => {
        axiosMock.onPost(subscriptionSyncPath).reply(422, { success: false });
        createComponent({ stubs: { GlCard, SubscriptionDetailsCard } });
        findSubscriptionSyncAction().vm.$emit('click');
        return waitForPromises();
      });

      it('shows a failure notification', () => {
        expect(findSubscriptionSyncNotifications().props('notification')).toBe(
          notificationType.SYNC_FAILURE,
        );
      });

      it('dismisses the failure notification when retrying to sync', async () => {
        await findSubscriptionSyncAction().vm.$emit('click');

        expect(findSubscriptionSyncNotifications().exists()).toBe(false);
      });
    });
  });

  describe('with subscription history data', () => {
    beforeEach(() => {
      createComponent();
    });

    it('shows the subscription history', () => {
      expect(findDetailsHistory().exists()).toBe(true);
    });

    it('provides the correct props to the subscription history component', () => {
      expect(findDetailsHistory().props('currentSubscriptionId')).toBe(license.ULTIMATE.id);
      expect(findDetailsHistory().props('subscriptionList')).toBe(subscriptionHistory);
    });
  });

  describe('with no subscription data', () => {
    it('does not show user info', () => {
      createComponent({ props: { subscription: {} } });

      expect(findDetailsUserInfo().exists()).toBe(false);
    });

    it('does not show details', () => {
      createComponent({ props: { subscription: {}, subscriptionList: [] } });

      expect(findDetailsUserInfo().exists()).toBe(false);
    });
  });

  describe('with no subscription history data', () => {
    it('shows the current subscription as the only history item', () => {
      createComponent({ props: { subscriptionList: [] } });

      expect(findDetailsHistory().props('')).toMatchObject({
        currentSubscriptionId: license.ULTIMATE.id,
        subscriptionList: [license.ULTIMATE],
      });
    });
  });
});
