import Vue from 'vue';
import DiffLineNoteForm from '~/diffs/components/diff_line_note_form.vue';
import store from '~/mr_notes/stores';
import { createComponentWithStore } from 'spec/helpers/vue_mount_component_helper';
import diffFileMockData from '../mock_data/diff_file';

describe('DiffLineNoteForm', () => {
  let component;
  let diffFile;
  let diffLines;
  const getDiffFileMock = () => Object.assign({}, diffFileMockData);

  beforeEach(() => {
    diffFile = getDiffFileMock();
    diffLines = diffFile.highlightedDiffLines;

    component = createComponentWithStore(Vue.extend(DiffLineNoteForm), store, {
      diffFile,
      diffLines,
      line: diffLines[0],
      noteTargetLine: diffLines[0],
    }).$mount();
  });

  describe('methods', () => {
    describe('handleCancelCommentForm', () => {
      it('should call cancelCommentForm with lineCode', () => {
        spyOn(component, 'cancelCommentForm');
        component.handleCancelCommentForm();

        expect(component.cancelCommentForm).toHaveBeenCalledWith({
          lineCode: diffLines[0].lineCode,
        });
      });
    });

    describe('saveNoteForm', () => {
      it('should call saveNote action with proper params', done => {
        let isPromiseCalled = false;
        const formDataSpy = spyOnDependency(DiffLineNoteForm, 'getNoteFormData').and.returnValue({
          postData: 1,
        });
        const saveNoteSpy = spyOn(component, 'saveNote').and.returnValue(
          new Promise(() => {
            isPromiseCalled = true;
            done();
          }),
        );

        component.handleSaveNote('note body');

        expect(formDataSpy).toHaveBeenCalled();
        expect(saveNoteSpy).toHaveBeenCalled();
        expect(isPromiseCalled).toEqual(true);
      });
    });
  });

  describe('template', () => {
    it('should have note form', () => {
      const { $el } = component;

      expect($el.querySelector('.js-vue-textarea')).toBeDefined();
      expect($el.querySelector('.js-vue-issue-save')).toBeDefined();
      expect($el.querySelector('.js-vue-markdown-field')).toBeDefined();
    });
  });
});
