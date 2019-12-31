import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import store from 'ee/subscriptions/new/store';
import * as constants from 'ee/subscriptions/new/constants';
import component from 'ee/subscriptions/new/components/checkout/components/step.vue';
import StepSummary from 'ee/subscriptions/new/components/checkout/components/step_summary.vue';

describe('Step', () => {
  const localVue = createLocalVue();
  localVue.use(Vuex);

  let wrapper;

  const initialData = {
    step: 'secondStep',
    isValid: true,
    title: 'title',
    nextStepButtonText: 'next',
  };

  const factory = propsData => {
    wrapper = shallowMount(localVue.extend(component), {
      store,
      propsData: { ...initialData, ...propsData },
      localVue,
      sync: false,
    });
  };

  const activatePreviousStep = () => {
    store.dispatch('activateStep', 'firstStep');
  };

  constants.STEPS = ['firstStep', 'secondStep'];

  beforeEach(() => {
    store.dispatch('activateStep', 'secondStep');
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('isActive', () => {
    it('should return true when this step is the current step', () => {
      factory();

      expect(wrapper.vm.isActive).toEqual(true);
    });

    it('should return false when this step is not the current step', () => {
      activatePreviousStep();
      factory();

      expect(wrapper.vm.isActive).toEqual(false);
    });
  });

  describe('isFinished', () => {
    it('should return true when this step is valid and not active', () => {
      activatePreviousStep();
      factory();

      expect(wrapper.vm.isFinished).toEqual(true);
    });

    it('should return false when this step is not valid and not active', () => {
      activatePreviousStep();
      factory({ isValid: false });

      expect(wrapper.vm.isFinished).toEqual(false);
    });

    it('should return false when this step is valid and active', () => {
      factory();

      expect(wrapper.vm.isFinished).toEqual(false);
    });

    it('should return false when this step is not valid and active', () => {
      factory({ isValid: false });

      expect(wrapper.vm.isFinished).toEqual(false);
    });
  });

  describe('editable', () => {
    it('should return true when this step is finished and comes before the current step', () => {
      factory({ step: 'firstStep' });

      expect(wrapper.vm.editable).toEqual(true);
    });

    it('should return false when this step is not finished and comes before the current step', () => {
      factory({ step: 'firstStep', isValid: false });

      expect(wrapper.vm.editable).toEqual(false);
    });

    it('should return false when this step is finished and does not come before the current step', () => {
      activatePreviousStep();
      factory({ step: 'firstStep' });

      expect(wrapper.vm.editable).toEqual(false);
    });
  });

  describe('Showing the summary', () => {
    it('shows the summary when this step is finished', () => {
      activatePreviousStep();
      factory();

      expect(wrapper.find(StepSummary).exists()).toBe(true);
    });

    it('does not show the summary when this step is not finished', () => {
      factory();

      expect(wrapper.find(StepSummary).exists()).toBe(false);
    });
  });

  describe('Next button', () => {
    it('shows the next button when the text was passed', () => {
      factory();

      expect(wrapper.text()).toEqual('next');
    });

    it('does not show the next button when no text was passed', () => {
      factory({ nextStepButtonText: '' });

      expect(wrapper.text()).toEqual('');
    });

    it('is disabled when this step is not valid', () => {
      factory({ isValid: false });

      expect(wrapper.find(GlButton).attributes('disabled')).toBe('true');
    });

    it('is enabled when this step is valid', () => {
      factory();

      expect(wrapper.find(GlButton).attributes('disabled')).toBeUndefined();
    });
  });
});
