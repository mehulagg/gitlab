import { shallowMount } from '@vue/test-utils';
import createStore from 'ee/billings/stores';
import SubscriptionApp from 'ee/billings/components/app.vue';
import SubscriptionTable from 'ee/billings/components/subscription_table.vue';

describe('SubscriptionApp component', () => {
  let store;
  let wrapper;

  const appProps = {
    namespaceId: '42',
    namespaceName: 'bronze',
    planUpgradeHref: '/url',
    customerPortalUrl: 'https://customers.gitlab.com/subscriptions',
  };

  const factory = (props = appProps) => {
    store = createStore();
    jest.spyOn(store, 'dispatch').mockImplementation();

    wrapper = shallowMount(SubscriptionApp, {
      store,
      propsData: { ...props },
    });
  };

  const expectComponentWithProps = (Component, props = {}) => {
    const componentWrapper = wrapper.find(Component);

    expect(componentWrapper.isVisible()).toBeTruthy();
    expect(componentWrapper.props()).toEqual(expect.objectContaining(props));
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('on creation', () => {
    beforeEach(() => {
      factory();
    });

    it('dispatches the setNamespaceId on mounted', () => {
      expect(store.dispatch.mock.calls).toEqual([
        ['subscription/setNamespaceId', appProps.namespaceId],
      ]);
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });

    it('passes the correct props to the subscriptions table', () => {
      expectComponentWithProps(SubscriptionTable, {
        namespaceName: appProps.namespaceName,
        planUpgradeHref: appProps.planUpgradeHref,
        customerPortalUrl: appProps.customerPortalUrl,
      });
    });
  });
});
