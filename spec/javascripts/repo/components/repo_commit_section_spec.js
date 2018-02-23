import Vue from 'vue';
import * as urlUtils from '~/lib/utils/url_utility';
import store from '~/ide/stores';
import service from '~/ide/services';
import repoCommitSection from '~/ide/components/repo_commit_section.vue';
import getSetTimeoutPromise from '../../helpers/set_timeout_promise_helper';
import { createComponentWithStore } from '../../helpers/vue_mount_component_helper';
import { file, resetStore } from '../helpers';

describe('RepoCommitSection', () => {
  let vm;

  function createComponent() {
    const Component = Vue.extend(repoCommitSection);

    vm = createComponentWithStore(Component, store, {
      noChangesStateSvgPath: 'svg',
      committedStateSvgPath: 'commitsvg',
    });

    vm.$store.state.currentProjectId = 'abcproject';
    vm.$store.state.currentBranchId = 'master';
    vm.$store.state.projects.abcproject = {
      web_url: '',
      branches: {
        master: {
          workingReference: '1',
        },
      },
    };

    const files = [file('file1'), file('file2')].map(f => Object.assign(f, {
      type: 'blob',
    }));

    vm.$store.state.rightPanelCollapsed = false;
    vm.$store.state.currentBranch = 'master';
    vm.$store.state.changedFiles = [...files];
    vm.$store.state.changedFiles.forEach(f => Object.assign(f, {
      changed: true,
      content: 'changedFile testing',
    }));

    vm.$store.state.stagedFiles = [{ ...files[0] }, { ...files[1] }];
    vm.$store.state.stagedFiles.forEach(f => Object.assign(f, {
      changed: true,
      content: 'testing',
    }));

    return vm.$mount();
  }

  beforeEach((done) => {
    vm = createComponent();

    spyOn(service, 'getTreeData').and.returnValue(Promise.resolve({
      headers: {
        'page-title': 'test',
      },
      json: () => Promise.resolve({
        last_commit_path: 'last_commit_path',
        parent_tree_url: 'parent_tree_url',
        path: '/',
        trees: [{ name: 'tree' }],
        blobs: [{ name: 'blob' }],
        submodules: [{ name: 'submodule' }],
      }),
    }));

    Vue.nextTick(done);
  });

  afterEach(() => {
    vm.$destroy();

    resetStore(vm.$store);
  });

  describe('empty Stage', () => {
    it('renders no changes text', () => {
      resetStore(vm.$store);
      const Component = Vue.extend(repoCommitSection);

      vm = createComponentWithStore(Component, store, {
        noChangesStateSvgPath: 'nochangessvg',
        committedStateSvgPath: 'svg',
      }).$mount();

      // Vue.nextTick();

      expect(vm.$el.querySelector('.js-empty-state').textContent.trim()).toContain('No changes');
      expect(vm.$el.querySelector('.js-empty-state img').getAttribute('src')).toBe('nochangessvg');
    });
  });

  it('renders a commit section', () => {
    const changedFileElements = [...vm.$el.querySelectorAll('.multi-file-commit-list li')];
    const submitCommit = vm.$el.querySelector('form .btn');
    const allFiles = vm.$store.state.changedFiles.concat(vm.$store.state.stagedFiles);

    expect(vm.$el.querySelector('.multi-file-commit-form')).not.toBeNull();
    expect(changedFileElements.length).toEqual(4);

    changedFileElements.forEach((changedFile, i) => {
      expect(changedFile.textContent.trim()).toContain(allFiles[i].path);
    });

    expect(submitCommit.disabled).toBeTruthy();
    expect(submitCommit.querySelector('.fa-spinner.fa-spin')).toBeNull();
  });

  it('adds changed files into staged files', (done) => {
    vm.$el.querySelector('.ide-staged-action-btn').click();

    Vue.nextTick(() => {
      expect(vm.$el.querySelector('.ide-commit-list-container').textContent).toContain('No changes');

      done();
    });
  });

  it('stages a single file', (done) => {
    vm.$el.querySelector('.multi-file-discard-btn').click();

    Vue.nextTick(() => {
      expect(vm.$el.querySelector('.ide-commit-list-container').querySelectorAll('li').length).toBe(1);

      done();
    });
  });

  it('removes all staged files', (done) => {
    vm.$el.querySelectorAll('.ide-staged-action-btn')[1].click();

    Vue.nextTick(() => {
      expect(vm.$el.querySelectorAll('.ide-commit-list-container')[1].textContent).toContain('No changes');

      done();
    });
  });

  it('unstages a single file', (done) => {
    vm.$el.querySelectorAll('.multi-file-discard-btn')[2].click();

    Vue.nextTick(() => {
      expect(
        vm.$el.querySelectorAll('.ide-commit-list-container')[1].querySelectorAll('li').length,
      ).toBe(1);

      done();
    });
  });

  describe('when submitting', () => {
    let stagedFiles;

    beforeEach(() => {
      vm.commitMessage = 'testing';
      stagedFiles = JSON.parse(JSON.stringify(vm.$store.state.stagedFiles));

      spyOn(service, 'commit').and.returnValue(Promise.resolve({
        data: {
          short_id: '1',
          stats: {},
        },
      }));
    });

    it('allows you to submit', () => {
      expect(vm.$el.querySelector('form .btn').disabled).toBeTruthy();
    });

    it('submits commit', (done) => {
      vm.makeCommit();

      // Wait for the branch check to finish
      getSetTimeoutPromise()
        .then(() => Vue.nextTick())
        .then(() => {
          const args = service.commit.calls.allArgs()[0];
          const { commit_message, actions, branch: payloadBranch } = args[1];

          expect(commit_message).toBe('testing');
          expect(actions.length).toEqual(2);
          expect(payloadBranch).toEqual('master');
          expect(actions[0].action).toEqual('update');
          expect(actions[1].action).toEqual('update');
          expect(actions[0].content).toEqual(stagedFiles[0].content);
          expect(actions[1].content).toEqual(stagedFiles[1].content);
          expect(actions[0].file_path).toEqual(stagedFiles[0].path);
          expect(actions[1].file_path).toEqual(stagedFiles[1].path);

          vm.$store.state.changedFiles = [];
        })
        .then(Vue.nextTick)
        .then(() => {
          expect(vm.$el.querySelector('.js-empty-state').textContent.trim()).toContain('All changes are committed');
          expect(vm.$el.querySelector('.js-empty-state img').getAttribute('src')).toBe('commitsvg');
        })
        .then(done)
        .catch(done.fail);
    });

    it('redirects to MR creation page if start new MR checkbox checked', (done) => {
      spyOn(urlUtils, 'visitUrl');
      vm.startNewMR = true;

      vm.makeCommit();

      getSetTimeoutPromise()
        .then(() => Vue.nextTick())
        .then(() => {
          expect(urlUtils.visitUrl).toHaveBeenCalled();
        })
        .then(done)
        .catch(done.fail);
    });
  });
});
