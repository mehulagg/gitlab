import { GlButton, GlLoadingIcon } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import Api from 'ee/api';
import Component from 'ee/subscriptions/new/components/checkout/confirm_order.vue';
import createStore from 'ee/subscriptions/new/store';
import * as types from 'ee/subscriptions/new/store/mutation_types';

describe('Confirm Order', () => {
  const localVue = createLocalVue();
  localVue.use(Vuex);

  let wrapper;

  jest.mock('ee/api.js');

  const store = createStore();

  const createComponent = (opts = {}) => {
    wrapper = shallowMount(Component, {
      localVue,
      store,
      ...opts,
    });
  };

  const findConfirmButton = () => wrapper.find(GlButton);
  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Active', () => {
    beforeEach(() => {
      store.commit(types.UPDATE_CURRENT_STEP, 'confirmOrder');
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
    beforeEach(() => {
      store.commit(types.UPDATE_CURRENT_STEP, 'otherStep');
    });

    it('button should not be visible', () => {
      expect(findConfirmButton().exists()).toBe(false);
    });
  });
});
