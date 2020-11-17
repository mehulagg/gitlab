import { shallowMount } from '@vue/test-utils';
import SubscriptionApp from 'ee/billings/components/app.vue';
import SubscriptionSeats from 'ee/billings/components/subscription_seats.vue';
import SubscriptionTable from 'ee/billings/components/subscription_table.vue';
import createStore from 'ee/billings/stores';
import * as types from 'ee/billings/stores/modules/subscription/mutation_types';
import { mockDataSeats } from '../mock_data';

describe('SubscriptionApp component', () => {
  let store;
  let wrapper;

  const appProps = {
    namespaceId: '42',
    namespaceName: 'bronze',
    planUpgradeHref: '/url',
    customerPortalUrl: 'https://customers.gitlab.com/subscriptions',
  };

  const factory = (props = appProps, isFeatureEnabledApiBillableMemberList = true) => {
    store = createStore();
    jest.spyOn(store, 'dispatch').mockImplementation();

    wrapper = shallowMount(SubscriptionApp, {
      store,
      propsData: { ...props },
      provide: {
        glFeatures: { apiBillableMemberList: isFeatureEnabledApiBillableMemberList },
      },
    });
  };

  const expectComponentWithProps = (Component, props = {}) => {
    const componentWrapper = wrapper.find(Component);

    expect(componentWrapper.isVisible()).toBeTruthy();
    expect(componentWrapper.props()).toEqual(expect.objectContaining(props));
  };

  const findSubscriptionSeatsTable = () => wrapper.find(SubscriptionSeats);

  afterEach(() => {
    wrapper.destroy();
  });

  describe('on creation', () => {
    beforeEach(() => {
      factory();
      store.commit(`subscription/${types.RECEIVE_HAS_BILLABLE_MEMBERS_SUCCESS}`, mockDataSeats);
    });

    it('dispatches expected actions on created', () => {
      expect(store.dispatch.mock.calls).toEqual([
        ['subscription/setNamespaceId', '42'],
        ['subscription/fetchHasBillableGroupMembers', undefined],
      ]);
    });

    it('passes the correct props to the subscriptions table', () => {
      expectComponentWithProps(SubscriptionTable, {
        namespaceName: appProps.namespaceName,
        planUpgradeHref: appProps.planUpgradeHref,
        customerPortalUrl: appProps.customerPortalUrl,
      });
    });

    it('passes the correct props to the subscriptions seats component', () => {
      expectComponentWithProps(SubscriptionSeats, {
        namespaceName: appProps.namespaceName,
        namespaceId: appProps.namespaceId,
      });
    });
  });

  describe('when there are no billable members', () => {
    beforeEach(() => {
      factory();
      store.commit(`subscription/${types.RECEIVE_HAS_BILLABLE_MEMBERS_SUCCESS}`, {
        data: [],
        headers: {},
      });
    });

    it('does not render the subscription seats table', () => {
      expect(findSubscriptionSeatsTable().exists()).toBe(false);
    });
  });

  describe('when feature flag is disabled', () => {
    beforeEach(() => {
      factory(appProps, false);
    });

    it('does not dispatch fetchBillableGroupMembers action on created', () => {
      expect(store.dispatch.mock.calls).not.toContainEqual([
        'subscription/fetchBillableGroupMembers',
        undefined,
      ]);
    });

    it('does not render the subscription seats table', () => {
      expect(findSubscriptionSeatsTable().exists()).toBe(false);
    });
  });
});
