import Vue from 'vue';
import MockAdapter from 'axios-mock-adapter';
import '~/behaviors/markdown/render_gfm';
import axios from '~/lib/utils/axios_utils';
import store from '~/ide/stores';
import repoEditor from '~/ide/components/repo_editor.vue';
import Editor from '~/ide/lib/editor';
import { activityBarViews } from '~/ide/constants';
import { createComponentWithStore } from '../../helpers/vue_mount_component_helper';
import setTimeoutPromise from '../../helpers/set_timeout_promise_helper';
import { file, resetStore } from '../helpers';

describe('RepoEditor', () => {
  let vm;

  beforeEach(done => {
    const f = file();
    const RepoEditor = Vue.extend(repoEditor);

    vm = createComponentWithStore(RepoEditor, store, {
      file: f,
    });

    f.active = true;
    f.tempFile = true;
    vm.$store.state.openFiles.push(f);
    Vue.set(vm.$store.state.entries, f.path, f);

    spyOn(vm, 'getFileData').and.returnValue(Promise.resolve());

    vm.$mount();

    Vue.nextTick(() => setTimeout(done));
  });

  afterEach(() => {
    vm.$destroy();

    resetStore(vm.$store);

    Editor.editorInstance.dispose();
  });

  it('renders an ide container', done => {
    Vue.nextTick(() => {
      expect(vm.shouldHideEditor).toBeFalsy();

      done();
    });
  });

  it('renders only an edit tab', done => {
    Vue.nextTick(() => {
      const tabs = vm.$el.querySelectorAll('.ide-mode-tabs .nav-links li');
      expect(tabs.length).toBe(1);
      expect(tabs[0].textContent.trim()).toBe('Edit');

      done();
    });
  });

  describe('when file is markdown', () => {
    beforeEach(done => {
      vm.file.previewMode = {
        id: 'markdown',
        previewTitle: 'Preview Markdown',
      };

      vm.$nextTick(done);
    });

    it('renders an Edit and a Preview Tab', done => {
      Vue.nextTick(() => {
        const tabs = vm.$el.querySelectorAll('.ide-mode-tabs .nav-links li');
        expect(tabs.length).toBe(2);
        expect(tabs[0].textContent.trim()).toBe('Edit');
        expect(tabs[1].textContent.trim()).toBe('Preview Markdown');

        done();
      });
    });
  });

  describe('when file is markdown and viewer mode is review', () => {
    let mock;

    beforeEach(done => {
      mock = new MockAdapter(axios);

      vm.file.projectId = 'namespace/project';
      vm.file.previewMode = {
        id: 'markdown',
        previewTitle: 'Preview Markdown',
      };
      vm.file.content = 'testing 123';
      vm.$store.state.viewer = 'diff';

      mock.onPost(/(.*)\/preview_markdown/).reply(200, {
        body: '<p>testing 123</p>',
      });

      vm.$nextTick(done);
    });

    afterEach(() => {
      mock.restore();
    });

    it('renders an Edit and a Preview Tab', done => {
      Vue.nextTick(() => {
        const tabs = vm.$el.querySelectorAll('.ide-mode-tabs .nav-links li');
        expect(tabs.length).toBe(2);
        expect(tabs[0].textContent.trim()).toBe('Review');
        expect(tabs[1].textContent.trim()).toBe('Preview Markdown');

        done();
      });
    });

    it('renders markdown for tempFile', done => {
      vm.file.tempFile = true;
      vm.file.path = `${vm.file.path}.md`;
      vm.$store.state.entries[vm.file.path] = vm.file;

      vm
        .$nextTick()
        .then(() => {
          vm.$el.querySelectorAll('.ide-mode-tabs .nav-links a')[1].click();
        })
        .then(setTimeoutPromise)
        .then(() => {
          expect(vm.$el.querySelector('.preview-container').innerHTML).toContain(
            '<p>testing 123</p>',
          );
        })
        .then(done)
        .catch(done.fail);
    });
  });

  describe('when open file is binary and not raw', () => {
    beforeEach(done => {
      vm.file.binary = true;

      vm.$nextTick(done);
    });

    it('does not render the IDE', () => {
      expect(vm.shouldHideEditor).toBeTruthy();
    });
  });

  describe('createEditorInstance', () => {
    it('calls createInstance when viewer is editor', done => {
      spyOn(vm.editor, 'createInstance');

      vm.createEditorInstance();

      vm.$nextTick(() => {
        expect(vm.editor.createInstance).toHaveBeenCalled();

        done();
      });
    });

    it('calls createDiffInstance when viewer is diff', done => {
      vm.$store.state.viewer = 'diff';

      spyOn(vm.editor, 'createDiffInstance');

      vm.createEditorInstance();

      vm.$nextTick(() => {
        expect(vm.editor.createDiffInstance).toHaveBeenCalled();

        done();
      });
    });

    it('calls createDiffInstance when viewer is a merge request diff', done => {
      vm.$store.state.viewer = 'mrdiff';

      spyOn(vm.editor, 'createDiffInstance');

      vm.createEditorInstance();

      vm.$nextTick(() => {
        expect(vm.editor.createDiffInstance).toHaveBeenCalled();

        done();
      });
    });
  });

  describe('setupEditor', () => {
    it('creates new model', () => {
      spyOn(vm.editor, 'createModel').and.callThrough();

      Editor.editorInstance.modelManager.dispose();

      vm.setupEditor();

      expect(vm.editor.createModel).toHaveBeenCalledWith(vm.file, null);
      expect(vm.model).not.toBeNull();
    });

    it('attaches model to editor', () => {
      spyOn(vm.editor, 'attachModel').and.callThrough();

      Editor.editorInstance.modelManager.dispose();

      vm.setupEditor();

      expect(vm.editor.attachModel).toHaveBeenCalledWith(vm.model);
    });

    it('attaches model to merge request editor', () => {
      vm.$store.state.viewer = 'mrdiff';
      vm.file.mrChange = true;
      spyOn(vm.editor, 'attachMergeRequestModel');

      Editor.editorInstance.modelManager.dispose();

      vm.setupEditor();

      expect(vm.editor.attachMergeRequestModel).toHaveBeenCalledWith(vm.model);
    });

    it('does not attach model to merge request editor when not a MR change', () => {
      vm.$store.state.viewer = 'mrdiff';
      vm.file.mrChange = false;
      spyOn(vm.editor, 'attachMergeRequestModel');

      Editor.editorInstance.modelManager.dispose();

      vm.setupEditor();

      expect(vm.editor.attachMergeRequestModel).not.toHaveBeenCalledWith(vm.model);
    });

    it('adds callback methods', () => {
      spyOn(vm.editor, 'onPositionChange').and.callThrough();

      Editor.editorInstance.modelManager.dispose();

      vm.setupEditor();

      expect(vm.editor.onPositionChange).toHaveBeenCalled();
      expect(vm.model.events.size).toBe(2);
    });

    it('updates state when model content changed', done => {
      vm.model.setValue('testing 123');

      setTimeout(() => {
        expect(vm.file.content).toBe('testing 123');

        done();
      });
    });

    it('sets head model as staged file', () => {
      spyOn(vm.editor, 'createModel').and.callThrough();

      Editor.editorInstance.modelManager.dispose();

      vm.$store.state.stagedFiles.push({ ...vm.file, key: 'staged' });
      vm.file.staged = true;
      vm.file.key = `unstaged-${vm.file.key}`;

      vm.setupEditor();

      expect(vm.editor.createModel).toHaveBeenCalledWith(vm.file, vm.$store.state.stagedFiles[0]);
    });
  });

  describe('editor updateDimensions', () => {
    beforeEach(() => {
      spyOn(vm.editor, 'updateDimensions').and.callThrough();
      spyOn(vm.editor, 'updateDiffView');
    });

    it('calls updateDimensions when rightPanelCollapsed is changed', done => {
      vm.$store.state.rightPanelCollapsed = true;

      vm.$nextTick(() => {
        expect(vm.editor.updateDimensions).toHaveBeenCalled();
        expect(vm.editor.updateDiffView).toHaveBeenCalled();

        done();
      });
    });

    it('calls updateDimensions when panelResizing is false', done => {
      vm.$store.state.panelResizing = true;

      vm
        .$nextTick()
        .then(() => {
          vm.$store.state.panelResizing = false;
        })
        .then(vm.$nextTick)
        .then(() => {
          expect(vm.editor.updateDimensions).toHaveBeenCalled();
          expect(vm.editor.updateDiffView).toHaveBeenCalled();
        })
        .then(done)
        .catch(done.fail);
    });

    it('does not call updateDimensions when panelResizing is true', done => {
      vm.$store.state.panelResizing = true;

      vm.$nextTick(() => {
        expect(vm.editor.updateDimensions).not.toHaveBeenCalled();
        expect(vm.editor.updateDiffView).not.toHaveBeenCalled();

        done();
      });
    });

    it('calls updateDimensions when rightPane is updated', done => {
      vm.$store.state.rightPane = 'testing';

      vm.$nextTick(() => {
        expect(vm.editor.updateDimensions).toHaveBeenCalled();
        expect(vm.editor.updateDiffView).toHaveBeenCalled();

        done();
      });
    });
  });

  describe('show tabs', () => {
    it('shows tabs in edit mode', () => {
      expect(vm.$el.querySelector('.nav-links')).not.toBe(null);
    });

    it('hides tabs in review mode', done => {
      vm.$store.state.currentActivityView = activityBarViews.review;

      vm.$nextTick(() => {
        expect(vm.$el.querySelector('.nav-links')).toBe(null);

        done();
      });
    });

    it('hides tabs in commit mode', done => {
      vm.$store.state.currentActivityView = activityBarViews.commit;

      vm.$nextTick(() => {
        expect(vm.$el.querySelector('.nav-links')).toBe(null);

        done();
      });
    });
  });

  it('calls removePendingTab when old file is pending', done => {
    spyOnProperty(vm, 'shouldHideEditor').and.returnValue(true);
    spyOn(vm, 'removePendingTab');

    vm.file.pending = true;

    vm
      .$nextTick()
      .then(() => {
        vm.file = file('testing');

        return vm.$nextTick();
      })
      .then(() => {
        expect(vm.removePendingTab).toHaveBeenCalled();
      })
      .then(done)
      .catch(done.fail);
  });
});
