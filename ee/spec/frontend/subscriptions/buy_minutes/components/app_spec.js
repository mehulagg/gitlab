import { GlEmptyState } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import App from 'ee/subscriptions/buy_minutes/components/app.vue';
import plansQuery from 'ee/subscriptions/buy_minutes/graphql/queries/plans.query.customer.graphql';
import StepOrderApp from 'ee/vue_shared/purchase_flow/components/step_order_app.vue';
import { createMockClient } from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { mockCiMinutesPlans } from '../mock_data';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('App', () => {
  let wrapper;

  function createMockApolloProvider(mockResponses = {}) {
    const {
      plansQueryMock = jest.fn().mockResolvedValue({ data: { plans: mockCiMinutesPlans } }),
    } = mockResponses;

    const mockDefaultClient = createMockClient();
    const mockCustomerClient = createMockClient([[plansQuery, plansQueryMock]]);

    return new VueApollo({
      defaultClient: mockDefaultClient,
      clients: { customerClient: mockCustomerClient },
    });
  }

  function createComponent(options = {}) {
    const { apolloProvider, propsData } = options;
    return shallowMount(App, {
      localVue,
      propsData,
      apolloProvider,
    });
  }

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when data is received', () => {
    it('should display the StepOrderApp', async () => {
      const mockApollo = createMockApolloProvider();
      wrapper = createComponent({ apolloProvider: mockApollo });
      await waitForPromises();

      expect(wrapper.find(StepOrderApp).exists()).toBe(true);
      expect(wrapper.find(GlEmptyState).exists()).toBe(false);
    });
  });

  describe('when data is not received', () => {
    it('should display the GlEmptyState', async () => {
      const mockApollo = createMockApolloProvider({
        plansQueryMock: jest.fn().mockRejectedValue(new Error('An error happened!')),
      });
      wrapper = createComponent({ apolloProvider: mockApollo });
      await waitForPromises();

      expect(wrapper.find(StepOrderApp).exists()).toBe(false);
      expect(wrapper.find(GlEmptyState).exists()).toBe(true);
    });
  });
});
