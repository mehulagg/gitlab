import { createLocalVue, shallowMount } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import CloudLicenseApp from 'ee/pages/admin/cloud_licenses/components/app.vue';
import SubscriptionActivationForm from 'ee/pages/admin/cloud_licenses/components/subscription_activation_form.vue';
import SubscriptionBreakdown from 'ee/pages/admin/cloud_licenses/components/subscription_breakdown.vue';
import {
  subscriptionActivationTitle,
  subscriptionHistoryQueries,
  subscriptionMainTitle,
  subscriptionQueries,
} from 'ee/pages/admin/cloud_licenses/constants';
import createMockApollo from 'helpers/mock_apollo_helper';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { license, subscriptionHistory } from '../mock_data';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('CloudLicenseApp', () => {
  let wrapper;

  const findActivateSubscriptionForm = () => wrapper.findComponent(SubscriptionActivationForm);
  const findSubscriptionBreakdown = () => wrapper.findComponent(SubscriptionBreakdown);
  const findSubscriptionActivationTitle = () =>
    wrapper.findByTestId('subscription-activation-title');
  const findSubscriptionMainTitle = () => wrapper.findByTestId('subscription-main-title');

  let currentSubscriptionResolver;
  let subscriptionHistoryResolver;
  const createMockApolloProvider = ([subscriptionResolver, historyResolver]) => {
    localVue.use(VueApollo);
    return createMockApollo([
      [subscriptionQueries.query, subscriptionResolver],
      [subscriptionHistoryQueries.query, historyResolver],
    ]);
  };

  const createComponent = (props = {}, resolverMock) => {
    wrapper = extendedWrapper(
      shallowMount(CloudLicenseApp, {
        localVue,
        apolloProvider: createMockApolloProvider(resolverMock),
        propsData: {
          ...props,
        },
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
    currentSubscriptionResolver.mockRestore();
    subscriptionHistoryResolver.mockRestore();
  });

  describe('Subscription Activation Form', () => {
    beforeEach(() => {
      currentSubscriptionResolver = jest
        .fn()
        .mockResolvedValue({ data: { currentLicense: license.ULTIMATE } });
      subscriptionHistoryResolver = jest
        .fn()
        .mockResolvedValue({ data: { licenseHistoryEntries: { nodes: subscriptionHistory } } });
      createComponent({}, [currentSubscriptionResolver, subscriptionHistoryResolver]);
    });

    it('shows the main title', () => {
      expect(findSubscriptionMainTitle().text()).toBe(subscriptionMainTitle);
    });

    describe('without an active license', () => {
      it('shows a title saying there is no active subscription', () => {
        expect(findSubscriptionActivationTitle().text()).toBe(subscriptionActivationTitle);
      });

      it('does not query for the current license', () => {
        expect(currentSubscriptionResolver).toHaveBeenCalledTimes(0);
      });

      it('queries for the current history', () => {
        expect(subscriptionHistoryResolver).toHaveBeenCalledTimes(1);
      });

      it('shows the subscription activation form', () => {
        expect(findActivateSubscriptionForm().exists()).toBe(true);
      });
    });

    describe('with active license', () => {
      beforeEach(() => {
        currentSubscriptionResolver = jest
          .fn()
          .mockResolvedValue({ data: { currentLicense: license.ULTIMATE } });
        subscriptionHistoryResolver = jest
          .fn()
          .mockResolvedValue({ data: { licenseHistoryEntries: { nodes: subscriptionHistory } } });
        createComponent({ hasActiveLicense: true }, [
          currentSubscriptionResolver,
          subscriptionHistoryResolver,
        ]);
      });

      it('queries for the current license', () => {
        expect(currentSubscriptionResolver).toHaveBeenCalledTimes(1);
      });

      it('queries for the current history', () => {
        expect(subscriptionHistoryResolver).toHaveBeenCalledTimes(1);
      });

      it('passes the correct data to the subscription breakdown', () => {
        expect(findSubscriptionBreakdown().props()).toMatchObject({
          subscription: license.ULTIMATE,
          subscriptionList: subscriptionHistory,
        });
      });
    });
  });
});
