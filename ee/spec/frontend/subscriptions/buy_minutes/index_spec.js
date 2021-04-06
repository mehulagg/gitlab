import { GlEmptyState } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { createWrapper } from '@vue/test-utils';

import initBuyMinutesApp from 'ee/subscriptions/buy_minutes';
import * as utils from 'ee/subscriptions/buy_minutes/utils';
import StepOrderApp from 'ee/vue_shared/components/step_order_app.vue';
import { mockCiMinutesPlans, mockParsedCiMinutesPlans } from './mock_data';

jest.mock('ee/subscriptions/buy_minutes/utils');

describe('initBuyMinutesApp', () => {
  let vm;
  let wrapper;

  function createComponent() {
    const el = document.createElement('div');
    Object.assign(el.dataset, { ciMinutesPlans: mockCiMinutesPlans, groupData: '[]' });
    vm = initBuyMinutesApp(el).$mount();
    wrapper = createWrapper(vm);
  }

  beforeEach(() => {
    Sentry.captureException = jest.fn();
  });

  afterEach(() => {
    if (vm) {
      vm.$destroy();
    }
    wrapper.destroy();
    vm = null;
    Sentry.captureException.mockClear();
    utils.parseData.mockClear();
  });

  describe('when parsing fails', () => {
    it('displays the EmptyState', () => {
      utils.parseData.mockImplementation(() => {
        throw new Error();
      });
      createComponent();
      expect(wrapper.find(StepOrderApp).exists()).toBe(false);
      expect(wrapper.find(GlEmptyState).exists()).toBe(true);
      expect(Sentry.captureException).not.toHaveBeenCalled();
    });
  });

  describe('when parsing succeeds', () => {
    it('displays the StepOrderApp', () => {
      utils.parseData.mockImplementation(() => mockParsedCiMinutesPlans);
      createComponent();
      expect(wrapper.find(GlEmptyState).exists()).toBe(false);
      expect(wrapper.find(StepOrderApp).exists()).toBe(true);
      expect(Sentry.captureException).not.toHaveBeenCalled();
    });
  });
});
