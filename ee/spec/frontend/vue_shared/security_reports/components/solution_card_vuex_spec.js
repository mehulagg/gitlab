import Vue from 'vue';
import component from 'ee/vue_shared/security_reports/components/solution_card.vue';
import { shallowMount } from '@vue/test-utils';
import { s__ } from '~/locale';

describe('Solution Card', () => {
  const Component = Vue.extend(component);
  const solution = 'Upgrade to XYZ';
  const remediation = { summary: 'Update to 123', fixes: [], diff: 'SGVsbG8gR2l0TGFi' };
  const vulnerabilityFeedbackHelpPath = '/foo';

  let wrapper;

  const findSolutionTitle = () => wrapper.find('h3');
  const findSolutionContent = () => wrapper.find({ ref: 'solution-text' });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('computed properties', () => {
    describe('solutionText', () => {
      it('takes the value of solution', () => {
        const propsData = { solution };
        wrapper = shallowMount(Component, { propsData });

        expect(findSolutionContent().text()).toBe(solution);
      });

      it('takes the summary from a remediation', () => {
        const propsData = { remediation };
        wrapper = shallowMount(Component, { propsData });

        expect(findSolutionContent().text()).toEqual(remediation.summary);
      });

      it('takes the summary from a remediation, if both are defined', () => {
        const propsData = { remediation, solution };
        wrapper = shallowMount(Component, { propsData });

        expect(findSolutionContent().text()).toEqual(remediation.summary);
      });
    });
  });

  describe('rendering', () => {
    describe('with solution', () => {
      beforeEach(() => {
        const propsData = { solution };
        wrapper = shallowMount(Component, { propsData });
      });

      it('renders the solution title', () => {
        expect(findSolutionTitle().text()).toBe('Solution');
      });

      it('renders the solution text', () => {
        expect(findSolutionContent().text()).toBe(solution);
      });
    });

    describe('with remediation', () => {
      beforeEach(() => {
        const propsData = { remediation, vulnerabilityFeedbackHelpPath, hasRemediation: true };
        wrapper = shallowMount(Component, { propsData });
      });

      it('renders the solution text and label', () => {
        expect(findSolutionContent().text()).toContain(remediation.summary);
      });

      describe('with download patch', () => {
        beforeEach(() => {
          wrapper.setProps({ hasDownload: true });
          return wrapper.vm.$nextTick();
        });

        it('renders the create a merge request to implement this solution message', () => {
          expect(findSolutionContent().text()).toContain(
            s__(
              'ciReport|Create a merge request to implement this solution, or download and apply the patch manually.',
            ),
          );
        });
      });

      describe('without download patch', () => {
        it('does not render the create a merge request to implement this solution message', () => {
          expect(findSolutionContent().text()).not.toContain(
            s__(
              'ciReport|Create a merge request to implement this solution, or download and apply the patch manually.',
            ),
          );
        });
      });
    });
  });
});
