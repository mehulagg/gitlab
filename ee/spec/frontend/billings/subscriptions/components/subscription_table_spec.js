import { GlLoadingIcon } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import SubscriptionTable from 'ee/billings/subscriptions/components/subscription_table.vue';
import SubscriptionTableRow from 'ee/billings/subscriptions/components/subscription_table_row.vue';
import initialStore from 'ee/billings/subscriptions/store';
import * as types from 'ee/billings/subscriptions/store/mutation_types';
import { mockDataSubscription } from 'ee_jest/billings/mock_data';
import { TEST_HOST } from 'helpers/test_constants';
import Vuex from 'vuex';
import { extendedWrapper } from '../../../../../../spec/frontend/helpers/vue_test_utils_helper';

const TEST_NAMESPACE_NAME = 'GitLab.com';
const CUSTOMER_PORTAL_URL = 'https://customers.gitlab.com/subscriptions';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('SubscriptionTable component', () => {
  let store;
  let wrapper;

  const findAddSeatsButton = () => wrapper.findByTestId('add-seats');
  const findButtonProps = () =>
    wrapper.findAll('a').wrappers.map(x => ({ text: x.text(), href: x.attributes('href') }));
  const findRenewButton = () => findButtonProps().filter(({ text }) => text === 'Renew');

  const factory = (
    options = {},
    { saasManualRenewButton = false, saasAddSeatsButton = false } = {},
  ) => {
    store = new Vuex.Store(initialStore());
    jest.spyOn(store, 'dispatch').mockImplementation();

    wrapper = extendedWrapper(
      shallowMount(SubscriptionTable, {
        store,
        localVue,
        provide: {
          glFeatures: {
            saasManualRenewButton,
            saasAddSeatsButton,
          },
        },
        ...options,
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when created', () => {
    beforeEach(() => {
      factory({
        propsData: {
          namespaceName: TEST_NAMESPACE_NAME,
          planUpgradeHref: '/url/',
          planRenewHref: '/url/for/renew',
          customerPortalUrl: CUSTOMER_PORTAL_URL,
        },
      });

      Object.assign(store.state, { isLoadingSubscription: true });
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
    ${'free'}       | ${true}    | ${true}    | ${false}    | ${'has Upgrade and Renew and Manage buttons'}
    ${'trial-gold'} | ${false}   | ${false}   | ${true}     | ${'has Manage button'}
    ${'gold'}       | ${false}   | ${false}   | ${false}    | ${'has Renew and Manage buttons'}
    ${'bronze'}     | ${false}   | ${true}    | ${false}    | ${'has Upgrade and Renew and Manage buttons'}
  `(
    'given a $planName plan with state: isFreePlan=$isFreePlan, upgradable=$upgradable, isTrialPlan=$isTrialPlan',
    ({ planName, isFreePlan, upgradable, snapshotDesc }) => {
      beforeEach(() => {
        const planUpgradeHref = `${TEST_HOST}/plan/upgrade/${planName}`;
        const planRenewHref = `${TEST_HOST}/plan/renew`;

        factory({
          propsData: {
            namespaceName: TEST_NAMESPACE_NAME,
            customerPortalUrl: CUSTOMER_PORTAL_URL,
            planUpgradeHref,
            planRenewHref,
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
      });

      it(snapshotDesc, () => {
        expect(findButtonProps()).toMatchSnapshot();
      });
    },
  );

  describe.each`
    planName        | planCode    | isFreePlan | isTrialPlan | featureFlag | expectedBehavior | testDescription
    ${'free'}       | ${null}     | ${true}    | ${false}    | ${true}     | ${false}         | ${'does not render the renew button for free plan'}
    ${'gold-trial'} | ${null}     | ${false}   | ${true}     | ${true}     | ${false}         | ${'does not render the renew button for trial plan'}
    ${'silver'}     | ${'silver'} | ${false}   | ${false}    | ${true}     | ${true}          | ${'renders the renew button for paid plans if feature flag is on'}
    ${'silver'}     | ${'silver'} | ${false}   | ${false}    | ${false}    | ${false}         | ${'does not render the renew button for paid plans if feature flag is off'}
  `(
    'given plan with state: isFreePlan=$isFreePlan and feature flag saasManualRenewButton=$featureFlag',
    ({ planName, planCode, isFreePlan, featureFlag, testDescription, expectedBehavior }) => {
      beforeEach(() => {
        factory(
          {
            propsData: { namespaceName: TEST_NAMESPACE_NAME },
          },
          { saasManualRenewButton: featureFlag },
        );

        Object.assign(store.state, {
          isLoadingSubscription: false,
          isFreePlan,
          plan: {
            code: planCode,
            name: planName,
            upgradable: true,
          },
        });
      });

      it(testDescription, () => {
        expect(findRenewButton().length > 0).toBe(expectedBehavior);
      });
    },
  );

  describe.each`
    planCode    | featureFlag | expected | testDescription
    ${'silver'} | ${true}     | ${true}  | ${'renders the button'}
    ${'silver'} | ${false}    | ${false} | ${'does not render the button'}
    ${null}     | ${true}     | ${false} | ${'does not render the button'}
    ${null}     | ${false}    | ${false} | ${'does not render the button'}
  `(
    'given plan with state: planCode = $planCode and saasAddSeatsButton = $featureFlag',
    ({ planCode, featureFlag, expected, testDescription }) => {
      beforeEach(() => {
        factory(
          {
            propsData: { namespaceName: TEST_NAMESPACE_NAME },
          },
          {
            saasAddSeatsButton: featureFlag,
          },
        );

        Object.assign(store.state, {
          isLoadingSubscription: false,
          plan: {
            code: planCode,
            upgradable: true,
          },
        });
      });

      it(testDescription, () => {
        expect(findAddSeatsButton().exists()).toBe(expected);
      });
    },
  );
});
