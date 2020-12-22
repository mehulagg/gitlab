import { mount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import Component from 'ee/subscriptions/new/components/checkout/payment_method.vue';
import Step from 'ee/subscriptions/new/components/checkout/step.vue';
import createStore from 'ee/subscriptions/new/store';
import * as types from 'ee/subscriptions/new/store/mutation_types';

describe('Payment Method', () => {
  const localVue = createLocalVue();
  localVue.use(Vuex);

  let store;
  let wrapper;

  const createComponent = (opts = {}) => {
    wrapper = mount(Component, {
      localVue,
      store,
      ...opts,
    });
  };

  beforeEach(() => {
    store = createStore();

    store.commit(types.UPDATE_PAYMENT_METHOD_ID, 'paymentMethodId');
    store.commit(types.UPDATE_CREDIT_CARD_DETAILS, {
      credit_card_type: 'Visa',
      credit_card_mask_number: '************4242',
      credit_card_expiration_month: 12,
      credit_card_expiration_year: 2009,
    });

    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('validations', () => {
    const isStepValid = () => wrapper.find(Step).props('isValid');

    it('should be valid when paymentMethodId is defined', () => {
      expect(isStepValid()).toBe(true);
    });

    it('should be invalid when paymentMethodId is undefined', () => {
      store.commit(types.UPDATE_PAYMENT_METHOD_ID, null);

      return localVue.nextTick().then(() => {
        expect(isStepValid()).toBe(false);
      });
    });
  });

  describe('showing the summary', () => {
    it('should show the entered credit card details', () => {
      expect(wrapper.find('.js-summary-line-1').html().replace(/\s+/g, ' ')).toContain(
        'Visa ending in <strong>4242</strong>',
      );
    });

    it('should show the entered credit card expiration date', () => {
      expect(wrapper.find('.js-summary-line-2').text()).toEqual('Exp 12/09');
    });
  });
});
