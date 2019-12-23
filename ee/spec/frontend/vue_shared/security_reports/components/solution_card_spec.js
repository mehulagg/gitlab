import Vue from 'vue';
import component from 'ee/vue_shared/security_reports/components/solution_card.vue';
import { trimText } from 'helpers/text_helper';
import { shallowMount } from '@vue/test-utils';
import { s__ } from '~/locale';

describe('Solution Card', () => {
  const Component = Vue.extend(component);
  const solution = 'Upgrade to XYZ';
  const remediation = { summary: 'Update to 123', fixes: [], diff: 'SGVsbG8gR2l0TGFi' };
  const vulnerabilityFeedbackHelpPath = '/foo';

  let wrapper;

  afterEach(() => {
    wrapper.destroy();
  });

  describe('computed properties', () => {
    describe('solutionText', () => {
      it('takes the value of solution', () => {
        const propsData = { solution };
        wrapper = shallowMount(Component, { propsData });

        expect(wrapper.vm.solutionText).toEqual(solution);
      });

      it('takes the summary from a remediation', () => {
        const propsData = { remediation };
        wrapper = shallowMount(Component, { propsData });

        expect(wrapper.vm.solutionText).toEqual(remediation.summary);
      });

      it('takes the summary from a remediation, if both are defined', () => {
        const propsData = { remediation, solution };
        wrapper = shallowMount(Component, { propsData });

        expect(wrapper.vm.solutionText).toEqual(remediation.summary);
      });
    });
  });

  describe('rendering', () => {
    describe('with solution', () => {
      beforeEach(() => {
        const propsData = { solution };
        wrapper = shallowMount(Component, { propsData });
      });

      it('renders the solution text and label', () => {
        expect(trimText(wrapper.find('.card-body').text())).toContain(`Solution: ${solution}`);
      });

      it('does not render the card footer', () => {
        expect(wrapper.contains('.card-footer')).toBe(false);
      });

      it('does not render the download link', () => {
        expect(wrapper.contains('a')).toBe(false);
      });
    });

    describe('with remediation', () => {
      beforeEach(() => {
        const propsData = { remediation, vulnerabilityFeedbackHelpPath, hasRemediation: true };
        wrapper = shallowMount(Component, { propsData });
      });

      it('renders the solution text and label', () => {
        expect(trimText(wrapper.find('.card-body').text())).toContain(
          `Solution: ${remediation.summary}`,
        );
      });

      it('renders the card footer', () => {
        expect(wrapper.contains('.card-footer')).toBe(true);
      });

      describe('with download patch', () => {
        beforeEach(() => {
          wrapper.setProps({ hasDownload: true });
          return wrapper.vm.$nextTick();
        });

        it('renders the learn more about remediation solutions', () => {
          expect(wrapper.find('.card-footer').text()).toContain(
            s__('ciReport|Learn more about interacting with security reports'),
          );
        });

        it('does not render the download and apply solution message when there is a file download and a merge request already exists', () => {
          wrapper.setProps({ hasMr: true });
          return wrapper.vm.$nextTick().then(() => {
            expect(wrapper.contains('.card-footer')).toBe(false);
          });
        });

        it('renders the create a merge request to implement this solution message', () => {
          expect(wrapper.find('.card-footer').text()).toContain(
            s__(
              'ciReport|Create a merge request to implement this solution, or download and apply the patch manually.',
            ),
          );
        });
      });

      describe('without download patch', () => {
        it('renders the learn more about remediation solutions', () => {
          expect(wrapper.find('.card-footer').text()).toContain(
            s__('ciReport|Learn more about interacting with security reports'),
          );
        });

        it('does not render the download and apply solution message', () => {
          expect(wrapper.find('.card-footer').text()).not.toContain(
            s__('ciReport|Download and apply the patch manually to resolve.'),
          );
        });

        it('does not render the create a merge request to implement this solution message', () => {
          expect(wrapper.find('.card-footer').text()).not.toContain(
            s__(
              'ciReport|Create a merge request to implement this solution, or download and apply the patch manually.',
            ),
          );
        });
      });
    });
  });
});
