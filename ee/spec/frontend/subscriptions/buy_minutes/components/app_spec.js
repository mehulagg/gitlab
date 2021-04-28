import { GlEmptyState } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import App from 'ee/subscriptions/buy_minutes/components/app.vue';
import StepOrderApp from 'ee/vue_shared/purchase_flow/components/step_order_app.vue';
import waitForPromises from 'helpers/wait_for_promises';
import { createMockApolloProvider } from '../spec_helper';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('App', () => {
  let wrapper;

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

      expect(wrapper.findComponent(StepOrderApp).exists()).toBe(true);
      expect(wrapper.findComponent(GlEmptyState).exists()).toBe(false);
    });
  });

  describe('when data is not received', () => {
    it('should display the GlEmptyState for empty data', async () => {
      const mockApollo = createMockApolloProvider({
        plansQueryMock: jest.fn().mockResolvedValue({ data: null }),
      });
      wrapper = createComponent({ apolloProvider: mockApollo });
      await waitForPromises();

      expect(wrapper.findComponent(StepOrderApp).exists()).toBe(false);
      expect(wrapper.findComponent(GlEmptyState).exists()).toBe(true);
    });

    it('should display the GlEmptyState for empty plans', async () => {
      const mockApollo = createMockApolloProvider({
        plansQueryMock: jest.fn().mockResolvedValue({ data: { plans: null } }),
      });
      wrapper = createComponent({ apolloProvider: mockApollo });
      await waitForPromises();

      expect(wrapper.findComponent(StepOrderApp).exists()).toBe(false);
      expect(wrapper.findComponent(GlEmptyState).exists()).toBe(true);
    });

    it('should display the GlEmptyState for plans data of wrong type', async () => {
      const mockApollo = createMockApolloProvider({
        plansQueryMock: jest.fn().mockResolvedValue({ data: { plans: {} } }),
      });
      wrapper = createComponent({ apolloProvider: mockApollo });
      await waitForPromises();

      expect(wrapper.findComponent(StepOrderApp).exists()).toBe(false);
      expect(wrapper.findComponent(GlEmptyState).exists()).toBe(true);
    });
  });

  describe('when an error is received', () => {
    it('should display the GlEmptyState', async () => {
      const mockApollo = createMockApolloProvider({
        plansQueryMock: jest.fn().mockRejectedValue(new Error('An error happened!')),
      });
      wrapper = createComponent({ apolloProvider: mockApollo });
      await waitForPromises();

      expect(wrapper.findComponent(StepOrderApp).exists()).toBe(false);
      expect(wrapper.findComponent(GlEmptyState).exists()).toBe(true);
    });
  });
});
