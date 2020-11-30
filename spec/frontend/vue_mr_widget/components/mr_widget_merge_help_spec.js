import Vue from 'vue';
import mountComponent from 'helpers/vue_mount_component_helper';
import mergeHelpComponent from '~/vue_merge_request_widget/components/mr_widget_merge_help.vue';

describe('MRWidgetMergeHelp', () => {
  let vm;
  let Component;

  beforeEach(() => {
    Component = Vue.extend(mergeHelpComponent);
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('with missing branch', () => {
    beforeEach(() => {
      vm = mountComponent(Component, {
        missingBranch: 'this-is-not-the-branch-you-are-looking-for',
      });
    });

    it('renders missing branch information', () => {
      expect(
        vm.$el.textContent
          .trim()
          .replace(/[\r\n]+/g, ' ')
          .replace(/\s\s+/g, ' '),
      ).toBe(
        'If the this-is-not-the-branch-you-are-looking-for branch exists in your local repository, you can merge this merge request manually using the command line',
      );
    });

    it('renders button to open help modal', () => {
      expect(vm.$el.querySelector('.js-open-modal-help').textContent.trim()).toBe('command line');
    });
  });

  describe('without missing branch', () => {
    beforeEach(() => {
      vm = mountComponent(Component);
    });

    it('renders information about how to merge manually', () => {
      expect(
        vm.$el.textContent
          .trim()
          .replace(/[\r\n]+/g, ' ')
          .replace(/\s\s+/g, ' '),
      ).toBe('You can merge this merge request manually using the command line');
    });

    it('renders element to open a modal', () => {
      expect(vm.$el.querySelector('.js-open-modal-help').textContent.trim()).toBe('command line');
    });
  });
});
