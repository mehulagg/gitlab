import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import { GlLoadingIcon } from '@gitlab/ui';
import { TEST_HOST } from 'helpers/test_constants';
import initialStore from 'ee/billings/subscriptions/store';
import * as types from 'ee/billings/subscriptions/store/mutation_types';
import SubscriptionTable from 'ee/billings/subscriptions/components/subscription_table.vue';
import SubscriptionTableRow from 'ee/billings/subscriptions/components/subscription_table_row.vue';
import { mockDataSubscription } from 'ee_jest/billings/mock_data';

const TEST_NAMESPACE_NAME = 'GitLab.com';
const CUSTOMER_PORTAL_URL = 'https://customers.gitlab.com/subscriptions';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('SubscriptionTable component', () => {
  let store;
  let wrapper;

  const findButtonProps = () =>
    wrapper.findAll('a').wrappers.map(x => ({ text: x.text(), href: x.attributes('href') }));

  const factory = (options = {}) => {
    store = new Vuex.Store(initialStore());
    jest.spyOn(store, 'dispatch').mockImplementation();

    wrapper = shallowMount(SubscriptionTable, {
      ...options,
      store,
      localVue,
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

      Object.assign(store.state, { isLoadingSubscription: true });

      return wrapper.vm.$nextTick();
    });

    it('shows loading icon', () => {
      expect(wrapper.find(GlLoadingIcon).isVisible()).toBeTruthy();
    });

    it('dispatches the correct actions', () => {
      expect(store.dispatch).toHaveBeenCalledWith('fetchSubscription');
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });
  });

  describe('with success', () => {
    beforeEach(() => {
      factory({ propsData: { namespaceName: TEST_NAMESPACE_NAME } });

      store.state.isLoadingSubscription = false;
      store.commit(`${types.RECEIVE_SUBSCRIPTION_SUCCESS}`, mockDataSubscription.gold);

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

        Object.assign(store.state, {
          isLoadingSubscription: false,
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
