import { mount, createLocalVue } from '@vue/test-utils';
import { merge } from 'lodash';
import VueApollo from 'vue-apollo';
import OrderSummary from 'ee/subscriptions/buy_minutes/components/order_summary.vue';
import subscriptionsResolvers from 'ee/subscriptions/buy_minutes/graphql/resolvers';
import stateQuery from 'ee/subscriptions/graphql/queries/state.query.graphql';
import purchaseFlowResolvers from 'ee/vue_shared/purchase_flow/graphql/resolvers';
import {
  mockCiMinutesPlans,
  stateData as mockStateData,
} from 'ee_jest/subscriptions/buy_minutes/mock_data';
import createMockApollo from 'helpers/mock_apollo_helper';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('Order Summary', () => {
  const resolvers = { ...purchaseFlowResolvers, ...subscriptionsResolvers };
  const initialStateData = {
    selectedPlanId: 'silver',
  };
  let wrapper;

  const createMockApolloProvider = (stateData = {}) => {
    const mockApollo = createMockApollo([], resolvers);

    const data = merge({}, mockStateData, initialStateData, stateData);

    mockApollo.clients.defaultClient.cache.writeQuery({
      query: stateQuery,
      data,
    });

    return mockApollo;
  };

  const createComponent = (stateData) => {
    const apolloProvider = createMockApolloProvider(stateData);

    wrapper = mount(OrderSummary, {
      localVue,
      apolloProvider,
      propsData: {
        plans: mockCiMinutesPlans,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Changing the company name', () => {
    describe('When purchasing for a single user', () => {
      beforeEach(() => {
        createComponent({ isSetupForCompany: false });
      });

      it('should display the title with the passed name', () => {
        expect(wrapper.find('h4').text()).toContain("Full Name's GitLab subscription");
      });
    });

    describe('When purchasing for a company or group', () => {
      describe('Without a group name provided', () => {
        beforeEach(() => {
          createComponent({ isSetupForCompany: true });
        });

        it('should display the title with the default name', () => {
          expect(wrapper.find('h4').text()).toContain("Your organization's GitLab subscription");
        });
      });

      describe('With a group name provided', () => {
        beforeEach(() => {
          createComponent({
            isSetupForCompany: true,
            customer: { company: 'My group' },
          });
        });

        it('when given a group name, it should display the title with the group name', () => {
          expect(wrapper.find('h4').text()).toContain("My group's GitLab subscription");
        });
      });
    });
  });

  describe('Changing the plan', () => {
    beforeEach(() => {
      createComponent();
    });

    describe('the selected plan', () => {
      it('should display the chosen plan', () => {
        expect(wrapper.find('.js-selected-plan').text()).toContain('silver plan');
      });

      it('should display the correct formatted amount price per user', () => {
        expect(wrapper.find('.js-per-user').text()).toContain('$228 per user per year');
      });
    });

    describe('the default plan', () => {
      beforeEach(() => {
        createComponent({
          subscription: { quantity: 1 },
          selectedPlanId: 'bronze',
        });
      });

      it('should display the chosen plan', () => {
        expect(wrapper.find('.js-selected-plan').text()).toContain('bronze plan');
      });

      it('should display the correct formatted amount price per user', () => {
        expect(wrapper.find('.js-per-user').text()).toContain('$48 per user per year');
      });

      it('should display the correct formatted total amount', () => {
        expect(wrapper.find('.js-total-amount').text()).toContain('$48');
      });
    });
  });

  describe('Changing the number of users', () => {
    beforeEach(() => {
      createComponent({
        subscription: { quantity: 1 },
        selectedPlanId: 'silver',
      });
    });

    describe('the default of 1 selected user', () => {
      it('should display the correct number of users', () => {
        expect(wrapper.find('.js-number-of-users').text()).toContain('(x1)');
      });

      it('should display the correct formatted amount price per user', () => {
        expect(wrapper.find('.js-per-user').text()).toContain('$228 per user per year');
      });

      it('should display the correct multiplied formatted amount of the chosen plan', () => {
        expect(wrapper.find('.js-amount').text()).toContain('$228');
      });

      it('should display the correct formatted total amount', () => {
        expect(wrapper.find('.js-total-amount').text()).toContain('$228');
      });
    });

    describe('3 selected users', () => {
      beforeEach(() => {
        createComponent({
          subscription: { quantity: 3 },
          selectedPlanId: 'silver',
        });
      });

      it('should display the correct number of users', () => {
        expect(wrapper.find('.js-number-of-users').text()).toContain('(x3)');
      });

      it('should display the correct formatted amount price per user', () => {
        expect(wrapper.find('.js-per-user').text()).toContain('$228 per user per year');
      });

      it('should display the correct multiplied formatted amount of the chosen plan', () => {
        expect(wrapper.find('.js-amount').text()).toContain('$684');
      });

      it('should display the correct formatted total amount', () => {
        expect(wrapper.find('.js-total-amount').text()).toContain('$684');
      });
    });

    describe('no selected users', () => {
      beforeEach(() => {
        createComponent({
          subscription: { quantity: 0 },
          selectedPlanId: 'silver',
        });
      });

      it('should not display the number of users', () => {
        expect(wrapper.find('.js-number-of-users').exists()).toBe(false);
      });

      it('should display the correct formatted amount price per user', () => {
        expect(wrapper.find('.js-per-user').text()).toContain('$228 per user per year');
      });

      it('should not display the amount', () => {
        expect(wrapper.find('.js-amount').text()).toContain('-');
      });

      it('should display the correct formatted total amount', () => {
        expect(wrapper.find('.js-total-amount').text()).toContain('-');
      });
    });

    describe('date range', () => {
      beforeEach(() => {
        createComponent();
      });

      it('shows the formatted date range from the start date to one year in the future', () => {
        expect(wrapper.find('.js-dates').text()).toContain('Jul 6, 2020 - Jul 6, 2021');
      });
    });

    describe('tax rate', () => {
      beforeEach(() => {
        createComponent();
      });

      describe('a tax rate of 0', () => {
        it('should not display the total amount excluding vat', () => {
          expect(wrapper.find('.js-total-ex-vat').exists()).toBe(false);
        });

        it('should not display the vat amount', () => {
          expect(wrapper.find('.js-vat').exists()).toBe(false);
        });
      });
    });
  });
});
