import Vuex from 'vuex';
import { mount, createLocalVue } from '@vue/test-utils';
import createStore from 'ee/subscriptions/new/store';
import * as types from 'ee/subscriptions/new/store/mutation_types';
import Component from 'ee/subscriptions/new/components/order_summary.vue';

describe('Order Summary', () => {
  const localVue = createLocalVue();
  localVue.use(Vuex);

  let wrapper;

  const planData = [
    { id: 'firstPlanId', code: 'bronze', price_per_year: 48 },
    { id: 'secondPlanId', code: 'silver', price_per_year: 228 },
    { id: 'thirdPlanId', code: 'gold', price_per_year: 1188 },
  ];

  const initialData = {
    planData: JSON.stringify(planData),
    planId: 'thirdPlanId',
    namespaceId: null,
    fullName: 'Full Name',
  };

  const store = createStore(initialData);

  const createComponent = (opts = {}) => {
    wrapper = mount(Component, {
      localVue,
      store,
      ...opts,
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Changing the company name', () => {
    describe('When purchasing for a single user', () => {
      beforeEach(() => {
        store.commit(types.UPDATE_IS_SETUP_FOR_COMPANY, false);
      });

      it('should display the title with the passed name', () => {
        expect(wrapper.find('h4').text()).toContain("Full Name's GitLab subscription");
      });
    });

    describe('When purchasing for a company or group', () => {
      beforeEach(() => {
        store.commit(types.UPDATE_IS_SETUP_FOR_COMPANY, true);
      });

      describe('Without a group name provided', () => {
        it('should display the title with the default name', () => {
          expect(wrapper.find('h4').text()).toContain("Your organization's GitLab subscription");
        });
      });

      describe('With a group name provided', () => {
        beforeEach(() => {
          store.commit(types.UPDATE_ORGANIZATION_NAME, 'My group');
        });

        it('when given a group name, it should display the title with the group name', () => {
          expect(wrapper.find('h4').text()).toContain("My group's GitLab subscription");
        });
      });
    });
  });

  describe('Changing the plan', () => {
    describe('the selected plan', () => {
      it('should display the chosen plan', () => {
        expect(wrapper.find('.js-selected-plan').text()).toContain('Gold plan');
      });

      it('should display the correct formatted amount price per user', () => {
        expect(wrapper.find('.js-per-user').text()).toContain('$1,188 per user per year');
      });
    });

    describe('the default plan', () => {
      beforeEach(() => {
        store.commit(types.UPDATE_SELECTED_PLAN, 'firstPlanId');
        store.commit(types.UPDATE_NUMBER_OF_USERS, 1);
      });

      it('should display the chosen plan', () => {
        expect(wrapper.find('.js-selected-plan').text()).toContain('Bronze plan');
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
      store.commit(types.UPDATE_SELECTED_PLAN, 'thirdPlanId');
      store.commit(types.UPDATE_NUMBER_OF_USERS, 1);
    });

    describe('the default of 1 selected user', () => {
      it('should display the correct number of users', () => {
        expect(wrapper.find('.js-number-of-users').text()).toContain('(x1)');
      });

      it('should display the correct formatted amount price per user', () => {
        expect(wrapper.find('.js-per-user').text()).toContain('$1,188 per user per year');
      });

      it('should display the correct multiplied formatted amount of the chosen plan', () => {
        expect(wrapper.find('.js-amount').text()).toContain('$1,188');
      });

      it('should display the correct formatted total amount', () => {
        expect(wrapper.find('.js-total-amount').text()).toContain('$1,188');
      });
    });

    describe('3 selected users', () => {
      beforeEach(() => {
        store.commit(types.UPDATE_SELECTED_PLAN, 'thirdPlanId');
        store.commit(types.UPDATE_NUMBER_OF_USERS, 3);
      });

      it('should display the correct number of users', () => {
        expect(wrapper.find('.js-number-of-users').text()).toContain('(x3)');
      });

      it('should display the correct formatted amount price per user', () => {
        expect(wrapper.find('.js-per-user').text()).toContain('$1,188 per user per year');
      });

      it('should display the correct multiplied formatted amount of the chosen plan', () => {
        expect(wrapper.find('.js-amount').text()).toContain('$3,564');
      });

      it('should display the correct formatted total amount', () => {
        expect(wrapper.find('.js-total-amount').text()).toContain('$3,564');
      });
    });

    describe('no selected users', () => {
      beforeEach(() => {
        store.commit(types.UPDATE_SELECTED_PLAN, 'thirdPlanId');
        store.commit(types.UPDATE_NUMBER_OF_USERS, 0);
      });

      it('should not display the number of users', () => {
        expect(wrapper.find('.js-number-of-users').exists()).toBe(false);
      });

      it('should display the correct formatted amount price per user', () => {
        expect(wrapper.find('.js-per-user').text()).toContain('$1,188 per user per year');
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
        store.state.startDate = new Date('2019-12-05');
      });

      it('shows the formatted date range from the start date to one year in the future', () => {
        expect(wrapper.find('.js-dates').text()).toContain('Dec 5, 2019 - Dec 5, 2020');
      });
    });

    describe('tax rate', () => {
      describe('a tax rate of 0', () => {
        it('should not display the total amount excluding vat', () => {
          expect(wrapper.find('.js-total-ex-vat').exists()).toBe(false);
        });

        it('should not display the vat amount', () => {
          expect(wrapper.find('.js-vat').exists()).toBe(false);
        });
      });

      describe('a tax rate of 8%', () => {
        beforeEach(() => {
          store.state.taxRate = 0.08;
        });

        it('should display the total amount excluding vat', () => {
          expect(wrapper.find('.js-total-ex-vat').text()).toContain('$1,188');
        });

        it('should display the vat amount', () => {
          expect(wrapper.find('.js-vat').text()).toContain('$95.04');
        });

        it('should display the total amount including the vat', () => {
          expect(wrapper.find('.js-total-amount').text()).toContain('$1,283.04');
        });
      });
    });
  });
});
