import { GlLoadingIcon } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import SubscriptionTable from 'ee/billings/subscriptions/components/subscription_table.vue';
import SubscriptionTableRow from 'ee/billings/subscriptions/components/subscription_table_row.vue';
import initialStore from 'ee/billings/subscriptions/store';
import * as types from 'ee/billings/subscriptions/store/mutation_types';
import { mockDataSubscription } from 'ee_jest/billings/mock_data';
import Vuex from 'vuex';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

const namespaceName = 'GitLab.com';
const customerPortalUrl = 'https://customers.gitlab.com/subscriptions';
const planName = 'Gold';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('SubscriptionTable component', () => {
  let store;
  let wrapper;

  const defaultFlags = { saasManualRenewButton: false, saasAddSeatsButton: false };

  const findAddSeatsButton = () => wrapper.findByTestId('add-seats-button');
  const findManageButton = () => wrapper.findByTestId('manage-button');
  const findRenewButton = () => wrapper.findByTestId('renew-button');
  const findUpgradeButton = () => wrapper.findByTestId('upgrade-button');

  const createComponentWithStore = ({
    props = {},
    featureFlags = {},
    provide = {},
    state = {},
  } = {}) => {
    store = new Vuex.Store(initialStore());
    jest.spyOn(store, 'dispatch').mockImplementation();

    wrapper = extendedWrapper(
      shallowMount(SubscriptionTable, {
        store,
        localVue,
        provide: {
          customerPortalUrl,
          namespaceName,
          planName,
          ...provide,
          glFeatures: {
            defaultFlags,
            ...featureFlags,
          },
        },
        propsData: props,
      }),
    );

    Object.assign(store.state, state);
    return wrapper.vm.$nextTick();
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when created', () => {
    beforeEach(() => {
      createComponentWithStore({
        provide: {
          planUpgradeHref: '/url/',
          planRenewHref: '/url/for/renew',
        },
        state: { isLoadingSubscription: true },
      });
    });

    it('shows loading icon', () => {
      expect(wrapper.find(GlLoadingIcon).isVisible()).toBeTruthy();
    });

    it('dispatches the correct actions', () => {
      expect(store.dispatch).toHaveBeenCalledWith('fetchSubscription');
    });
  });

  describe('with success', () => {
    beforeEach(() => {
      createComponentWithStore();
      store.state.isLoadingSubscription = false;
      store.commit(`${types.RECEIVE_SUBSCRIPTION_SUCCESS}`, mockDataSubscription.gold);
      return wrapper.vm.$nextTick();
    });

    it('should render the card title "GitLab.com: Gold"', () => {
      expect(wrapper.findByTestId('subscription-header').text()).toContain('GitLab.com: Gold');
    });

    it('should render a "Usage" and a "Billing" row', () => {
      expect(wrapper.findAll(SubscriptionTableRow)).toHaveLength(2);
    });
  });

  describe('when it is a trial', () => {
    it('should render the card title "GitLab.com: Trial"', async () => {
      await createComponentWithStore({
        state: {
          plan: {
            code: 'gold',
            trial: true,
          },
        },
      });
      expect(wrapper.findByTestId('subscription-header').text()).toContain('Trial');
    });
  });

  describe('Manage button', () => {
    describe.each`
      planCode    | expected | testDescription
      ${'bronze'} | ${true}  | ${'renders the button'}
      ${null}     | ${false} | ${'does not render the button'}
      ${'free'}   | ${false} | ${'does not render the button'}
    `(
      'given a plan with state: planCode = $planCode and saasAddSeatsButton = $featureFlag',
      ({ planCode, upgradable, expected, testDescription }) => {
        beforeEach(() => {
          createComponentWithStore({
            state: {
              isLoadingSubscription: false,
              plan: {
                code: planCode,
                upgradable,
              },
            },
          });
        });

        it(testDescription, () => {
          expect(findManageButton().exists()).toBe(expected);
        });
      },
    );
  });

  describe('Renew button', () => {
    describe.each`
      planCode    | featureFlag | expected | testDescription
      ${'silver'} | ${true}     | ${true}  | ${'renders the button'}
      ${'silver'} | ${false}    | ${false} | ${'does not render the button'}
      ${null}     | ${true}     | ${false} | ${'does not render the button'}
      ${null}     | ${false}    | ${false} | ${'does not render the button'}
      ${'free'}   | ${true}     | ${false} | ${'does not render the button'}
      ${'free'}   | ${false}    | ${false} | ${'does not render the button'}
    `(
      'given a plan with state: planCode = $planCode and saasManualRenewButton = $featureFlag',
      ({ planCode, featureFlag, expected, testDescription }) => {
        beforeEach(() => {
          createComponentWithStore({
            featureFlags: { saasManualRenewButton: featureFlag },
            state: {
              isLoadingSubscription: false,
              plan: {
                code: planCode,
              },
            },
          });
        });

        it(testDescription, () => {
          expect(findRenewButton().exists()).toBe(expected);
        });
      },
    );
  });

  describe('Add seats button', () => {
    describe.each`
      planCode    | featureFlag | expected | testDescription
      ${'silver'} | ${true}     | ${true}  | ${'renders the button'}
      ${'silver'} | ${false}    | ${false} | ${'does not render the button'}
      ${null}     | ${true}     | ${false} | ${'does not render the button'}
      ${null}     | ${false}    | ${false} | ${'does not render the button'}
      ${'free'}   | ${true}     | ${false} | ${'does not render the button'}
      ${'free'}   | ${false}    | ${false} | ${'does not render the button'}
    `(
      'given a plan with state: planCode = $planCode and saasAddSeatsButton = $featureFlag',
      ({ planCode, featureFlag, expected, testDescription }) => {
        beforeEach(() => {
          createComponentWithStore({
            featureFlags: { saasAddSeatsButton: featureFlag },
            state: {
              isLoadingSubscription: false,
              plan: {
                code: planCode,
                upgradable: true,
              },
            },
          });
        });

        it(testDescription, () => {
          expect(findAddSeatsButton().exists()).toBe(expected);
        });
      },
    );
  });

  describe('Upgrade button', () => {
    describe.each`
      planCode    | upgradable | expected | testDescription
      ${'bronze'} | ${true}    | ${true}  | ${'renders the button'}
      ${'bronze'} | ${false}   | ${false} | ${'does not render the button'}
      ${null}     | ${true}    | ${true}  | ${'renders the button'}
      ${null}     | ${false}   | ${true}  | ${'renders the button'}
      ${'free'}   | ${true}    | ${true}  | ${'renders the button'}
      ${'free'}   | ${false}   | ${true}  | ${'renders the button'}
    `(
      'given a plan with state: planCode = $planCode, upgradable = $upgradable',
      ({ planCode, upgradable, expected, testDescription }) => {
        beforeEach(() => {
          createComponentWithStore({
            provide: {
              planUpgradeHref: '',
            },
            state: {
              isLoadingSubscription: false,
              plan: {
                code: planCode,
                upgradable,
              },
            },
          });
        });

        it(testDescription, () => {
          expect(findUpgradeButton().exists()).toBe(expected);
        });
      },
    );
  });
});
