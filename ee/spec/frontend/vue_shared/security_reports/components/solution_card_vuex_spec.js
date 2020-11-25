import { shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import component from 'ee/vue_shared/security_reports/components/solution_card_vuex.vue';
import { trimText } from 'helpers/text_helper';
import { s__ } from '~/locale';

describe('Solution Card', () => {
  const Component = Vue.extend(component);
  const solution = 'Upgrade to XYZ';
  const remediation = { summary: 'Update to 123', fixes: [], diff: 'SGVsbG8gR2l0TGFi' };

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
        expect(wrapper.find('.card-footer').exists()).toBe(false);
      });

      it('does not render the download link', () => {
        expect(wrapper.find('a').exists()).toBe(false);
      });
    });

    describe('with remediation', () => {
      beforeEach(() => {
        const propsData = { remediation, hasRemediation: true };
        wrapper = shallowMount(Component, { propsData });
      });

      it('renders the solution text and label', () => {
        expect(trimText(wrapper.find('.card-body').text())).toContain(
          `Solution: ${remediation.summary}`,
        );
      });

      describe('with download patch', () => {
        beforeEach(() => {
          wrapper.setProps({ hasDownload: true });
          return wrapper.vm.$nextTick();
        });

        it('does not render the download and apply solution message when there is a file download and a merge request already exists', () => {
          wrapper.setProps({ hasMr: true });
          return wrapper.vm.$nextTick().then(() => {
            expect(wrapper.find('.card-footer').exists()).toBe(false);
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
        it('does not render the card footer', () => {
          expect(wrapper.find('.card-footer').exists()).toBe(false);
        });
      });
    });
  });
});
