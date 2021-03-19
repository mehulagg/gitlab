import { GlButton } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import Component from 'ee/subscriptions/new/components/checkout/step.vue';
import StepSummary from 'ee/subscriptions/new/components/checkout/step_summary.vue';
import * as constants from 'ee/subscriptions/new/constants';
import createStore from 'ee/subscriptions/new/store';

describe('Step', () => {
  const localVue = createLocalVue();
  localVue.use(Vuex);

  let store;
  let wrapper;

  const initialProps = {
    step: 'secondStep',
    isValid: true,
    title: 'title',
    nextStepButtonText: 'next',
  };

  const createComponent = (propsData) => {
    wrapper = shallowMount(Component, {
      propsData: { ...initialProps, ...propsData },
      localVue,
      store,
    });
  };

  const activatePreviousStep = () => {
    store.dispatch('activateStep', 'firstStep');
  };

  constants.STEPS = ['firstStep', 'secondStep'];

  beforeEach(() => {
    store = createStore();
    store.dispatch('activateStep', 'secondStep');
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Step Body', () => {
    it('should display the step body when this step is the current step', () => {
      createComponent();

      expect(wrapper.find('.card > div').attributes('style')).toBeUndefined();
    });

    it('should not display the step body when this step is not the current step', () => {
      activatePreviousStep();
      createComponent();

      expect(wrapper.find('.card > div').attributes('style')).toBe('display: none;');
    });
  });

  describe('Step Summary', () => {
    it('should be shown when this step is valid and not active', () => {
      activatePreviousStep();
      createComponent();

      expect(wrapper.find(StepSummary).exists()).toBe(true);
    });

    it('should not be shown when this step is not valid and not active', () => {
      activatePreviousStep();
      createComponent({ isValid: false });

      expect(wrapper.find(StepSummary).exists()).toBe(false);
    });

    it('should not be shown when this step is valid and active', () => {
      createComponent();

      expect(wrapper.find(StepSummary).exists()).toBe(false);
    });

    it('should not be shown when this step is not valid and active', () => {
      createComponent({ isValid: false });

      expect(wrapper.find(StepSummary).exists()).toBe(false);
    });
  });

  describe('isEditable', () => {
    it('should set the isEditable property to true when this step is finished and comes before the current step', () => {
      createComponent({ step: 'firstStep' });

      expect(wrapper.find(StepSummary).props('isEditable')).toBe(true);
    });
  });

  describe('Showing the summary', () => {
    it('shows the summary when this step is finished', () => {
      activatePreviousStep();
      createComponent();

      expect(wrapper.find(StepSummary).exists()).toBe(true);
    });

    it('does not show the summary when this step is not finished', () => {
      createComponent();

      expect(wrapper.find(StepSummary).exists()).toBe(false);
    });
  });

  describe('Next button', () => {
    it('shows the next button when the text was passed', () => {
      createComponent();

      expect(wrapper.text()).toBe('next');
    });

    it('does not show the next button when no text was passed', () => {
      createComponent({ nextStepButtonText: '' });

      expect(wrapper.text()).toBe('');
    });

    it('is disabled when this step is not valid', () => {
      createComponent({ isValid: false });

      expect(wrapper.find(GlButton).attributes('disabled')).toBe('true');
    });

    it('is enabled when this step is valid', () => {
      createComponent();

      expect(wrapper.find(GlButton).attributes('disabled')).toBeUndefined();
    });
  });
});
