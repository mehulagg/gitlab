import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import initialStore from 'ee/billings/subscriptions/store';
import SubscriptionApp from 'ee/billings/subscriptions/components/app.vue';
import * as types from 'ee/billings/subscriptions/store/mutation_types';
import { mockDataSeats } from 'ee_jest/billings/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('SubscriptionApp component', () => {
  let store;
  let wrapper;

  const providedFields = {
    namespaceId: '42',
    namespaceName: 'bronze',
    planUpgradeHref: '/url',
    planRenewHref: '/url/for/renew',
    customerPortalUrl: 'https://customers.gitlab.com/subscriptions',
  };

  const factory = () => {
    store = new Vuex.Store(initialStore());
    jest.spyOn(store, 'dispatch').mockImplementation();

    wrapper = shallowMount(SubscriptionApp, {
      store,
      provide: {
        ...providedFields,
      },
      localVue,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('on creation', () => {
    beforeEach(() => {
      factory();
      store.commit(`${types.RECEIVE_HAS_BILLABLE_MEMBERS_SUCCESS}`, mockDataSeats);
    });

    it('dispatches expected actions on created', () => {
      expect(store.dispatch.mock.calls).toEqual([['setNamespaceId', '42']]);
    });
  });
});
