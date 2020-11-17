import { mount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import Component from 'ee/subscriptions/new/components/checkout/billing_address.vue';
import Step from 'ee/subscriptions/new/components/checkout/step.vue';
import createStore from 'ee/subscriptions/new/store';
import * as types from 'ee/subscriptions/new/store/mutation_types';

describe('Billing Address', () => {
  const localVue = createLocalVue();
  localVue.use(Vuex);

  let store;
  let wrapper;

  const methodMocks = {
    fetchCountries: jest.fn(),
    fetchStates: jest.fn(),
  };

  const createComponent = () => {
    wrapper = mount(Component, {
      localVue,
      store,
      methods: methodMocks,
    });
  };

  beforeEach(() => {
    store = createStore();
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('mounted', () => {
    it('should load the countries', () => {
      expect(methodMocks.fetchCountries).toHaveBeenCalled();
    });
  });

  describe('country options', () => {
    const countrySelect = () => wrapper.find('.js-country');

    beforeEach(() => {
      store.commit(types.UPDATE_COUNTRY_OPTIONS, [{ text: 'Netherlands', value: 'NL' }]);
    });

    it('should display the select prompt', () => {
      expect(countrySelect().html()).toContain('<option value="">Please select a country</option>');
    });

    it('should display the countries returned from the server', () => {
      expect(countrySelect().html()).toContain('<option value="NL">Netherlands</option>');
    });

    it('should fetch states when selecting a country', () => {
      countrySelect().trigger('change');

      return localVue.nextTick().then(() => {
        expect(methodMocks.fetchStates).toHaveBeenCalled();
      });
    });
  });

  describe('validations', () => {
    const isStepValid = () => wrapper.find(Step).props('isValid');

    beforeEach(() => {
      store.commit(types.UPDATE_COUNTRY, 'country');
      store.commit(types.UPDATE_STREET_ADDRESS_LINE_ONE, 'address line 1');
      store.commit(types.UPDATE_CITY, 'city');
      store.commit(types.UPDATE_ZIP_CODE, 'zip');
    });

    it('should be valid when country, streetAddressLine1, city and zipCode have been entered', () => {
      expect(isStepValid()).toBe(true);
    });

    it('should be invalid when country is undefined', () => {
      store.commit(types.UPDATE_COUNTRY, null);

      return localVue.nextTick().then(() => {
        expect(isStepValid()).toBe(false);
      });
    });

    it('should be invalid when streetAddressLine1 is undefined', () => {
      store.commit(types.UPDATE_STREET_ADDRESS_LINE_ONE, null);

      return localVue.nextTick().then(() => {
        expect(isStepValid()).toBe(false);
      });
    });

    it('should be invalid when city is undefined', () => {
      store.commit(types.UPDATE_CITY, null);

      return localVue.nextTick().then(() => {
        expect(isStepValid()).toBe(false);
      });
    });

    it('should be invalid when zipCode is undefined', () => {
      store.commit(types.UPDATE_ZIP_CODE, null);

      return localVue.nextTick().then(() => {
        expect(isStepValid()).toBe(false);
      });
    });
  });

  describe('showing the summary', () => {
    beforeEach(() => {
      store.commit(types.UPDATE_COUNTRY, 'country');
      store.commit(types.UPDATE_STREET_ADDRESS_LINE_ONE, 'address line 1');
      store.commit(types.UPDATE_STREET_ADDRESS_LINE_TWO, 'address line 2');
      store.commit(types.UPDATE_COUNTRY_STATE, 'state');
      store.commit(types.UPDATE_CITY, 'city');
      store.commit(types.UPDATE_ZIP_CODE, 'zip');
      store.commit(types.UPDATE_CURRENT_STEP, 'nextStep');
    });

    it('should show the entered address line 1', () => {
      expect(wrapper.find('.js-summary-line-1').text()).toEqual('address line 1');
    });

    it('should show the entered address line 2', () => {
      expect(wrapper.find('.js-summary-line-2').text()).toEqual('address line 2');
    });

    it('should show the entered address city, state and zip code', () => {
      expect(wrapper.find('.js-summary-line-3').text()).toEqual('city, state zip');
    });
  });
});
