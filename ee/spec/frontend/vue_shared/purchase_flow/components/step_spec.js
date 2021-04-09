import { GlButton } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import Step from 'ee/vue_shared/purchase_flow/components/step.vue';
import StepSummary from 'ee/vue_shared/purchase_flow/components/step_summary.vue';
import updateStepMutation from 'ee/vue_shared/purchase_flow/graphql/mutations/update_active_step.mutation.graphql';
import { STEPS } from '../mock_data';
import { createMockApolloProvider } from '../spec_helper';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('Step', () => {
  let wrapper;

  const initialProps = {
    stepId: STEPS[1].id,
    isValid: true,
    title: 'title',
    nextStepButtonText: 'next',
  };

  function activateFirstStep(apolloProvider) {
    return apolloProvider.clients.defaultClient.mutate({
      mutation: updateStepMutation,
      variables: { id: STEPS[0].id },
    });
  }
  function createComponent(options = {}) {
    const { apolloProvider, propsData } = options;
    return shallowMount(Step, {
      localVue,
      propsData: { ...initialProps, ...propsData },
      apolloProvider,
    });
  }

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Step Body', () => {
    it('should display the step body when this step is the current step', () => {
      const mockApollo = createMockApolloProvider(STEPS, 1);
      wrapper = createComponent({ apolloProvider: mockApollo });

      expect(wrapper.find('.card > div').attributes('style')).toBeUndefined();
    });

    it('should not display the step body when this step is not the current step', async () => {
      const mockApollo = createMockApolloProvider(STEPS, 1);
      await activateFirstStep(mockApollo);
      wrapper = createComponent({ apolloProvider: mockApollo });

      expect(wrapper.find('.card > div').attributes('style')).toBe('display: none;');
    });
  });

  describe('Step Summary', () => {
    it('should be shown when this step is valid and not active', async () => {
      const mockApollo = createMockApolloProvider(STEPS, 1);
      await activateFirstStep(mockApollo);
      wrapper = createComponent({ apolloProvider: mockApollo });
      expect(wrapper.find(StepSummary).exists()).toBe(true);
    });

    it('should not be shown when this step is not valid and not active', async () => {
      const mockApollo = createMockApolloProvider(STEPS, 1);
      await activateFirstStep(mockApollo);
      wrapper = createComponent({ propsData: { isValid: false }, apolloProvider: mockApollo });

      expect(wrapper.find(StepSummary).exists()).toBe(false);
    });

    it('should not be shown when this step is valid and active', () => {
      const mockApollo = createMockApolloProvider(STEPS, 1);
      wrapper = createComponent({ apolloProvider: mockApollo });

      expect(wrapper.find(StepSummary).exists()).toBe(false);
    });

    it('should not be shown when this step is not valid and active', () => {
      const mockApollo = createMockApolloProvider(STEPS, 1);
      wrapper = createComponent({ propsData: { isValid: false }, apolloProvider: mockApollo });

      expect(wrapper.find(StepSummary).exists()).toBe(false);
    });
  });

  describe('isEditable', () => {
    it('should set the isEditable property to true when this step is finished and comes before the current step', () => {
      const mockApollo = createMockApolloProvider(STEPS, 1);
      wrapper = createComponent({ propsData: { stepId: STEPS[0].id }, apolloProvider: mockApollo });

      expect(wrapper.find(StepSummary).props('isEditable')).toBe(true);
    });
  });

  describe('Showing the summary', () => {
    it('shows the summary when this step is finished', async () => {
      const mockApollo = createMockApolloProvider(STEPS, 1);
      await activateFirstStep(mockApollo);
      wrapper = createComponent({ apolloProvider: mockApollo });

      expect(wrapper.find(StepSummary).exists()).toBe(true);
    });

    it('does not show the summary when this step is not finished', () => {
      const mockApollo = createMockApolloProvider(STEPS, 1);
      wrapper = createComponent({ apolloProvider: mockApollo });

      expect(wrapper.find(StepSummary).exists()).toBe(false);
    });
  });

  describe('Next button', () => {
    it('shows the next button when the text was passed', () => {
      const mockApollo = createMockApolloProvider(STEPS, 1);
      wrapper = createComponent({ apolloProvider: mockApollo });

      expect(wrapper.text()).toBe('next');
    });

    it('does not show the next button when no text was passed', () => {
      const mockApollo = createMockApolloProvider(STEPS, 1);
      wrapper = createComponent({
        propsData: { nextStepButtonText: '' },
        apolloProvider: mockApollo,
      });

      expect(wrapper.text()).toBe('');
    });

    it('is disabled when this step is not valid', () => {
      const mockApollo = createMockApolloProvider(STEPS, 1);
      wrapper = createComponent({ propsData: { isValid: false }, apolloProvider: mockApollo });

      expect(wrapper.find(GlButton).attributes('disabled')).toBe('true');
    });

    it('is enabled when this step is valid', () => {
      const mockApollo = createMockApolloProvider(STEPS, 1);
      wrapper = createComponent({ apolloProvider: mockApollo });

      expect(wrapper.find(GlButton).attributes('disabled')).toBeUndefined();
    });
  });
});
