import { shallowMount, createLocalVue } from '@vue/test-utils';
import { merge } from 'lodash';
import VueApollo from 'vue-apollo';
import ProgressBar from 'ee/registrations/components/progress_bar.vue';
import Checkout from 'ee/subscriptions/buy_minutes/components/checkout.vue';
import subscriptionsResolvers from 'ee/subscriptions/buy_minutes/graphql/resolvers';
import stateQuery from 'ee/subscriptions/graphql/queries/state.query.graphql';
import purchaseFlowResolvers from 'ee/vue_shared/purchase_flow/graphql/resolvers';
import {
  stateData as initialStateData,
  mockCiMinutesPlans,
} from 'ee_jest/subscriptions/buy_minutes/mock_data';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('Checkout', () => {
  const resolvers = merge({}, purchaseFlowResolvers, subscriptionsResolvers);
  let wrapper;

  const createMockApolloProvider = (stateData = {}) => {
    const mockApollo = createMockApollo([], resolvers);

    const data = merge({}, initialStateData, stateData);

    mockApollo.clients.defaultClient.cache.writeQuery({
      query: stateQuery,
      data,
    });

    return mockApollo;
  };

  const createComponent = (stateData = {}) => {
    const apolloProvider = createMockApolloProvider(stateData);

    wrapper = shallowMount(Checkout, {
      apolloProvider,
      localVue,
      propsData: {
        plans: mockCiMinutesPlans,
      },
    });
  };

  const findProgressBar = () => wrapper.find(ProgressBar);

  afterEach(() => {
    wrapper.destroy();
  });

  describe.each([
    [true, true],
    [false, false],
  ])('when isNewUser=%s', (isNewUser, visible) => {
    beforeEach(async () => {
      createComponent({ isNewUser });
    });

    it(`progress bar visibility is ${visible}`, () => {
      expect(findProgressBar().exists()).toBe(visible);
    });
  });

  describe('passing the correct options to the progress bar component', () => {
    beforeEach(async () => {
      createComponent({ isNewUser: true });
      await waitForPromises();
    });

    it('passes the steps', () => {
      expect(findProgressBar().props('steps')).toEqual([
        'Your profile',
        'Checkout',
        'Your GitLab group',
      ]);
    });

    it('passes the current step', () => {
      expect(findProgressBar().props('currentStep')).toEqual('Checkout');
    });
  });
});
