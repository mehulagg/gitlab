import Vue from 'vue';
import { createComponentWithStore } from 'helpers/vue_mount_component_helper';
import { projectData } from 'jest/ide/mock_data';
import store from '~/ide/stores';
import CommitForm from '~/ide/components/commit_sidebar/form.vue';
import { leftSidebarViews } from '~/ide/constants';
import { resetStore } from '../../helpers';

describe('IDE commit form', () => {
  const Component = Vue.extend(CommitForm);
  let vm;

  beforeEach(() => {
    store.state.changedFiles.push('test');
    store.state.currentProjectId = 'abcproject';
    store.state.currentBranchId = 'master';
    Vue.set(store.state.projects, 'abcproject', { ...projectData });

    vm = createComponentWithStore(Component, store).$mount();
  });

  afterEach(() => {
    vm.$destroy();

    resetStore(vm.$store);
  });

  it('enables button when has changes', () => {
    expect(vm.$el.querySelector('[disabled]')).toBe(null);
  });

  describe('compact', () => {
    beforeEach(() => {
      vm.isCompact = true;

      return vm.$nextTick();
    });

    it('renders commit button in compact mode', () => {
      expect(vm.$el.querySelector('.btn-primary')).not.toBeNull();
      expect(vm.$el.querySelector('.btn-primary').textContent).toContain('Commit');
    });

    it('does not render form', () => {
      expect(vm.$el.querySelector('form')).toBeNull();
    });

    it('renders overview text', () => {
      vm.$store.state.stagedFiles.push('test');

      return vm.$nextTick(() => {
        expect(vm.$el.querySelector('p').textContent).toContain('1 changed file');
      });
    });

    it('shows form when clicking commit button', () => {
      vm.$el.querySelector('.btn-primary').click();

      return vm.$nextTick(() => {
        expect(vm.$el.querySelector('form')).not.toBeNull();
      });
    });

    it('toggles activity bar view when clicking commit button', () => {
      vm.$el.querySelector('.btn-primary').click();

      return vm.$nextTick(() => {
        expect(store.state.currentActivityView).toBe(leftSidebarViews.commit.name);
      });
    });

    it('collapses if lastCommitMsg is set to empty and current view is not commit view', async () => {
      store.state.lastCommitMsg = 'abc';
      store.state.currentActivityView = leftSidebarViews.edit.name;
      await vm.$nextTick();

      // if commit message is set, form is uncollapsed
      expect(vm.isCompact).toBe(false);

      store.state.lastCommitMsg = '';
      await vm.$nextTick();

      // collapsed when set to empty
      expect(vm.isCompact).toBe(true);
    });
  });

  describe('full', () => {
    beforeEach(() => {
      vm.isCompact = false;

      return vm.$nextTick();
    });

    it('updates commitMessage in store on input', () => {
      const textarea = vm.$el.querySelector('textarea');

      textarea.value = 'testing commit message';

      textarea.dispatchEvent(new Event('input'));

      return vm.$nextTick().then(() => {
        expect(vm.$store.state.commit.commitMessage).toBe('testing commit message');
      });
    });

    it('updating currentActivityView not to commit view sets compact mode', () => {
      store.state.currentActivityView = 'a';

      return vm.$nextTick(() => {
        expect(vm.isCompact).toBe(true);
      });
    });

    it('always opens itself in full view current activity view is not commit view when clicking commit button', () => {
      vm.$el.querySelector('.btn-primary').click();

      return vm.$nextTick(() => {
        expect(store.state.currentActivityView).toBe(leftSidebarViews.commit.name);
        expect(vm.isCompact).toBe(false);
      });
    });

    describe('discard draft button', () => {
      it('hidden when commitMessage is empty', () => {
        expect(vm.$el.querySelector('.btn-default').textContent).toContain('Collapse');
      });

      it('resets commitMessage when clicking discard button', () => {
        vm.$store.state.commit.commitMessage = 'testing commit message';

        return vm
          .$nextTick()
          .then(() => {
            vm.$el.querySelector('.btn-default').click();
          })
          .then(() => vm.$nextTick())
          .then(() => {
            expect(vm.$store.state.commit.commitMessage).not.toBe('testing commit message');
          });
      });
    });

    describe('when submitting', () => {
      beforeEach(() => {
        jest.spyOn(vm, 'commitChanges');

        vm.$store.state.stagedFiles.push('test');
        vm.$store.state.commit.commitMessage = 'testing commit message';
      });

      it('calls commitChanges', () => {
        vm.commitChanges.mockResolvedValue({ success: true });

        return vm.$nextTick().then(() => {
          vm.$el.querySelector('.btn-success').click();

          expect(vm.commitChanges).toHaveBeenCalled();
        });
      });

      it('opens new branch modal if commitChanges throws an error', () => {
        vm.commitChanges.mockRejectedValue({ success: false });

        jest.spyOn(vm.$refs.createBranchModal, 'show').mockImplementation();

        return vm
          .$nextTick()
          .then(() => {
            vm.$el.querySelector('.btn-success').click();

            return vm.$nextTick();
          })
          .then(() => {
            expect(vm.$refs.createBranchModal.show).toHaveBeenCalled();
          });
      });
    });
  });

  describe('commitButtonText', () => {
    it('returns commit text when staged files exist', () => {
      vm.$store.state.stagedFiles.push('testing');

      expect(vm.commitButtonText).toBe('Commit');
    });

    it('returns stage & commit text when staged files do not exist', () => {
      expect(vm.commitButtonText).toBe('Stage & Commit');
    });
  });
});
