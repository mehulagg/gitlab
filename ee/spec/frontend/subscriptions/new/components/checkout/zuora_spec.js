import { GlLoadingIcon } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import Component from 'ee/subscriptions/new/components/checkout/zuora.vue';
import createStore from 'ee/subscriptions/new/store';
import * as types from 'ee/subscriptions/new/store/mutation_types';

describe('Zuora', () => {
  const localVue = createLocalVue();
  localVue.use(Vuex);

  let store;
  let wrapper;

  const methodMocks = {
    loadZuoraScript: jest.fn(),
    renderZuoraIframe: jest.fn(),
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(Component, {
      propsData: {
        active: true,
        ...props,
      },
      localVue,
      sync: false,
      store,
      methods: methodMocks,
    });
  };

  const findLoading = () => wrapper.find(GlLoadingIcon);
  const findZuoraPayment = () => wrapper.find('#zuora_payment');

  beforeEach(() => {
    store = createStore();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('mounted', () => {
    it('should call loadZuoraScript', () => {
      createComponent();

      expect(methodMocks.loadZuoraScript).toHaveBeenCalled();
    });
  });

  describe('when active', () => {
    beforeEach(() => {
      createComponent();
    });

    it('does not show the loading icon', () => {
      expect(findLoading().exists()).toBe(false);
    });

    it('the zuora_payment selector should be visible', () => {
      expect(findZuoraPayment().element.style.display).toEqual('');
    });

    describe('when toggling the loading indicator', () => {
      beforeEach(() => {
        store.commit(types.UPDATE_IS_LOADING_PAYMENT_METHOD, true);

        return localVue.nextTick();
      });

      it('shows the loading icon', () => {
        expect(findLoading().exists()).toBe(true);
      });

      it('the zuora_payment selector should not be visible', () => {
        expect(findZuoraPayment().element.style.display).toEqual('none');
      });
    });
  });

  describe('when not active', () => {
    beforeEach(() => {
      createComponent({ active: false });
    });

    it('does not show loading icon', () => {
      expect(findLoading().exists()).toBe(false);
    });

    it('the zuora_payment selector should not be visible', () => {
      expect(findZuoraPayment().element.style.display).toEqual('none');
    });
  });

  describe('renderZuoraIframe', () => {
    it('is called when the paymentFormParams are updated', () => {
      createComponent();

      expect(methodMocks.renderZuoraIframe).not.toHaveBeenCalled();

      store.commit(types.UPDATE_PAYMENT_FORM_PARAMS, {});

      return localVue.nextTick().then(() => {
        expect(methodMocks.renderZuoraIframe).toHaveBeenCalled();
      });
    });
  });
});
