import { shallowMount } from '@vue/test-utils';
import SubscriptionBreakdown, {
  licensedToFields,
  subscriptionDetailsFields,
} from 'ee/pages/admin/cloud_licenses/components/subscription_breakdown.vue';
import SubscriptionDetailsCard from 'ee/pages/admin/cloud_licenses/components/subscription_details_card.vue';
import SubscriptionDetailsHistory from 'ee/pages/admin/cloud_licenses/components/subscription_details_history.vue';
import SubscriptionDetailsUserInfo from 'ee/pages/admin/cloud_licenses/components/subscription_details_user_info.vue';
import {
  licensedToHeaderText,
  subscriptionDetailsHeaderText,
} from 'ee/pages/admin/cloud_licenses/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { license, subscriptionHistory } from '../mock_data';

describe('Subscription Breakdown', () => {
  let wrapper;

  const findDetailsCards = () => wrapper.findAllComponents(SubscriptionDetailsCard);
  const findDetailsHistory = () => wrapper.findComponent(SubscriptionDetailsHistory);
  const findDetailsUserInfo = () => wrapper.findComponent(SubscriptionDetailsUserInfo);

  const createComponent = ({ props, stubs } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(SubscriptionBreakdown, {
        propsData: {
          subscription: license.ULTIMATE,
          subscriptionList: subscriptionHistory,
          ...props,
        },
        stubs,
      }),
    );
  };

  afterEach(() => {
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

    it.todo('shows a button to sync the subscription');

    it.todo('shows a button to manage the subscription');
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

  describe('with empty data', () => {
    it('does not show user info', () => {
      createComponent({ props: { subscription: {} } });

      expect(findDetailsUserInfo().exists()).toBe(false);
    });

    it('does not show subscription history', () => {
      createComponent({ props: { subscriptionList: [] } });

      expect(findDetailsHistory().exists()).toBe(false);
    });
  });
});
