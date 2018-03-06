import Vue from 'vue';
import store from 'ee/ide/stores';
import repoEditor from 'ee/ide/components/repo_editor.vue';
import monacoLoader from 'ee/ide/monaco_loader';
import Editor from 'ee/ide/lib/editor';
import { file, resetStore } from '../helpers';

describe('RepoEditor', () => {
  let vm;

  beforeEach((done) => {
    const f = file();
    const RepoEditor = Vue.extend(repoEditor);

    vm = new RepoEditor({
      store,
    });

    f.active = true;
    f.tempFile = true;
    vm.$store.state.openFiles.push(f);
    vm.$store.getters.activeFile.html = 'testing';
    vm.monaco = true;

    vm.$mount();

    monacoLoader(['vs/editor/editor.main'], () => {
      setTimeout(done, 0);
    });
  });

  afterEach(() => {
    vm.$destroy();

    resetStore(vm.$store);

    Editor.editorInstance.modelManager.dispose();
  });

  it('renders an ide container', (done) => {
    Vue.nextTick(() => {
      expect(vm.shouldHideEditor).toBeFalsy();

      done();
    });
  });

  describe('when open file is binary and not raw', () => {
    beforeEach((done) => {
      vm.$store.getters.activeFile.binary = true;

      Vue.nextTick(done);
    });

    it('does not render the IDE', () => {
      expect(vm.shouldHideEditor).toBeTruthy();
    });

    it('shows activeFile html', () => {
      expect(vm.$el.textContent).toContain('testing');
    });
  });

  describe('setupEditor', () => {
    it('creates new model', () => {
      spyOn(vm.editor, 'createModel').and.callThrough();

      Editor.editorInstance.modelManager.dispose();

      vm.setupEditor();

      expect(vm.editor.createModel).toHaveBeenCalledWith(vm.$store.getters.activeFile);
      expect(vm.model).not.toBeNull();
    });

    it('attaches model to editor', () => {
      spyOn(vm.editor, 'attachModel').and.callThrough();

      Editor.editorInstance.modelManager.dispose();

      vm.setupEditor();

      expect(vm.editor.attachModel).toHaveBeenCalledWith(vm.model);
    });

    it('adds callback methods', () => {
      spyOn(vm.editor, 'onPositionChange').and.callThrough();

      Editor.editorInstance.modelManager.dispose();

      vm.setupEditor();

      expect(vm.editor.onPositionChange).toHaveBeenCalled();
      expect(vm.model.events.size).toBe(1);
    });

    it('updates state when model content changed', (done) => {
      vm.model.setValue('testing 123');

      setTimeout(() => {
        expect(vm.$store.getters.activeFile.content).toBe('testing 123');

        done();
      });
    });
  });
});
