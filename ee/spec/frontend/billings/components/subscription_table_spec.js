import { shallowMount } from '@vue/test-utils';
import { GlLoadingIcon } from '@gitlab/ui';
import { TEST_HOST } from 'helpers/test_constants';
import createStore from 'ee/billings/stores';
import * as types from 'ee/billings/stores/modules/subscription/mutation_types';
import SubscriptionTable from 'ee/billings/components/subscription_table.vue';
import SubscriptionTableRow from 'ee/billings/components/subscription_table_row.vue';
import mockDataSubscription from '../mock_data';

const TEST_NAMESPACE_NAME = 'GitLab.com';
const CUSTOMER_PORTAL_URL = 'https://customers.gitlab.com/subscriptions';

describe('SubscriptionTable component', () => {
  let store;
  let wrapper;

  const findButtonProps = () =>
    wrapper.findAll('a').wrappers.map(x => ({ text: x.text(), href: x.attributes('href') }));

  const factory = (options = {}) => {
    store = createStore();
    jest.spyOn(store, 'dispatch').mockImplementation();

    wrapper = shallowMount(SubscriptionTable, {
      ...options,
      store,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when created', () => {
    beforeEach(() => {
      factory({
        propsData: {
          namespaceName: TEST_NAMESPACE_NAME,
          planUpgradeHref: '/url/',
          customerPortalUrl: CUSTOMER_PORTAL_URL,
        },
      });

      Object.assign(store.state.subscription, { isLoading: true });

      return wrapper.vm.$nextTick();
    });

    it('shows loading icon', () => {
      expect(wrapper.find(GlLoadingIcon).isVisible()).toBeTruthy();
    });

    it('dispatches the correct actions', () => {
      expect(store.dispatch).toHaveBeenCalledWith('subscription/fetchSubscription', undefined);
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });
  });

  describe('with success', () => {
    beforeEach(() => {
      factory({ propsData: { namespaceName: TEST_NAMESPACE_NAME } });

      store.state.subscription.isLoading = false;
      store.commit(`subscription/${types.RECEIVE_SUBSCRIPTION_SUCCESS}`, mockDataSubscription.gold);

      return wrapper.vm.$nextTick();
    });

    it('should render the card title "GitLab.com: Gold"', () => {
      expect(
        wrapper
          .find('.js-subscription-header strong')
          .text()
          .trim(),
      ).toBe('GitLab.com: Gold');
    });

    it('should render a "Usage" and a "Billing" row', () => {
      expect(wrapper.findAll(SubscriptionTableRow)).toHaveLength(2);
    });
  });

  describe.each`
    planName        | isFreePlan | upgradable | isTrialPlan | snapshotDesc
    ${'free'}       | ${true}    | ${true}    | ${false}    | ${'has Upgrade and Manage buttons'}
    ${'trial-gold'} | ${false}   | ${false}   | ${true}     | ${'has Manage button'}
    ${'gold'}       | ${false}   | ${false}   | ${false}    | ${'has Manage button'}
    ${'bronze'}     | ${false}   | ${true}    | ${false}    | ${'has Upgrade and Manage buttons'}
  `(
    'given a $planName plan with state: isFreePlan=$isFreePlan, upgradable=$upgradable, isTrialPlan=$isTrialPlan',
    ({ planName, isFreePlan, upgradable, snapshotDesc }) => {
      beforeEach(() => {
        const planUpgradeHref = `${TEST_HOST}/plan/upgrade/${planName}`;

        factory({
          propsData: {
            namespaceName: TEST_NAMESPACE_NAME,
            customerPortalUrl: CUSTOMER_PORTAL_URL,
            planUpgradeHref,
          },
        });

        Object.assign(store.state.subscription, {
          isLoading: false,
          isFreePlan,
          plan: {
            code: planName,
            name: planName,
            upgradable,
          },
        });

        return wrapper.vm.$nextTick();
      });

      it(snapshotDesc, () => {
        expect(findButtonProps()).toMatchSnapshot();
      });
    },
  );
});
