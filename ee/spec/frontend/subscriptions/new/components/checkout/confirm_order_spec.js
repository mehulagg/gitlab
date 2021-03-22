import { GlButton, GlLoadingIcon } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import Vuex from 'vuex';
import Api from 'ee/api';
import ConfirmOrder from 'ee/subscriptions/new/components/checkout/confirm_order.vue';
import { STEPS } from 'ee/subscriptions/new/constants';
import createStore from 'ee/subscriptions/new/store';
import updateStepMutation from 'ee/vue_shared/purchase_flow/graphql/mutations/update_active_step.mutation.graphql';
import resolvers from 'ee/vue_shared/purchase_flow/graphql/resolvers';
import createMockApollo from 'helpers/mock_apollo_helper';

const stepList = STEPS.map((id) => ({ __typename: 'Step', id }));
const defaultInitialGraphqlData = {
  stepList,
  activeStep: stepList[0],
};

describe('Confirm Order', () => {
  const localVue = createLocalVue();
  localVue.use(Vuex);
  localVue.use(VueApollo);

  let wrapper;
  let mockApolloProvider;

  jest.mock('ee/api.js');

  const store = createStore();

  async function activateStep(stepId) {
    return mockApolloProvider.clients.defaultClient.mutate({
      mutation: updateStepMutation,
      variables: { id: stepId },
    });
  }

  function createMockApolloProvider(initialGraphqlData = defaultInitialGraphqlData) {
    const mockApollo = createMockApollo([], resolvers);
    mockApollo.clients.defaultClient.cache.writeData({ data: initialGraphqlData });

    return mockApollo;
  }

  function createComponent(options = {}) {
    return shallowMount(ConfirmOrder, {
      localVue,
      store,
      ...options,
    });
  }

  const findConfirmButton = () => wrapper.find(GlButton);
  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);

  beforeEach(() => {
    mockApolloProvider = createMockApolloProvider();
    wrapper = createComponent({ apolloProvider: mockApolloProvider });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Active', () => {
    beforeEach(async () => {
      await activateStep(stepList[3].id);
    });

    it('button should be visible', () => {
      expect(findConfirmButton().exists()).toBe(true);
    });

    it('shows the text "Confirm purchase"', () => {
      expect(findConfirmButton().text()).toBe('Confirm purchase');
    });

    it('the loading indicator should not be visible', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });

    describe('Clicking the button', () => {
      beforeEach(() => {
        Api.confirmOrder = jest.fn().mockReturnValue(new Promise(jest.fn()));

        findConfirmButton().vm.$emit('click');
      });

      it('calls the confirmOrder API method', () => {
        expect(Api.confirmOrder).toHaveBeenCalled();
      });

      it('shows the text "Confirming..."', () => {
        expect(findConfirmButton().text()).toBe('Confirming...');
      });

      it('the loading indicator should be visible', () => {
        expect(findLoadingIcon().exists()).toBe(true);
      });
    });
  });

  describe('Inactive', () => {
    beforeEach(async () => {
      await activateStep(stepList[1].id);
    });

    it('button should not be visible', () => {
      expect(findConfirmButton().exists()).toBe(false);
    });
  });
});
