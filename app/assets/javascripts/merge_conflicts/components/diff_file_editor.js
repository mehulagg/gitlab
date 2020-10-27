/* eslint-disable no-param-reassign */

import Vue from 'vue';
import { debounce } from 'lodash';
import axios from '~/lib/utils/axios_utils';
import { deprecatedCreateFlash as flash } from '~/flash';
import { __ } from '~/locale';

(global => {
  global.mergeConflicts = global.mergeConflicts || {};

  global.mergeConflicts.diffFileEditor = Vue.extend({
    props: {
      file: {
        type: Object,
        required: true,
      },
      onCancelDiscardConfirmation: {
        type: Function,
        required: true,
      },
      onAcceptDiscardConfirmation: {
        type: Function,
        required: true,
      },
    },
    data() {
      return {
        saved: false,
        fileLoaded: false,
        originalContent: '',
      };
    },
    computed: {
      classObject() {
        return {
          saved: this.saved,
        };
      },
    },
    watch: {
      'file.showEditor': function showEditorWatcher(val) {
        this.resetEditorContent();

        if (!val || this.fileLoaded) {
          return;
        }

        this.$nextTick(() => {
          this.loadEditor();
        });
      },
    },
    mounted() {
      if (this.file.loadEditor) {
        this.loadEditor();
      }
    },
    methods: {
      loadEditor() {
        this.editor = null;

        const EditorPromise = import(/* webpackChunkName: 'EditorLite' */ '~/editor/editor_lite');
        const DataPromise = axios.get(this.file.content_path);

        Promise.all([EditorPromise, DataPromise])
          .then(([{ default: EditorLite }, { data }]) => {
            const content = document.createTextNode(data.content).textContent;
            const path = data.new_path;
            this.originalContent = data.content;
            this.fileLoaded = true;

            const contentEl = this.$el.querySelector('.editor');

            this.editor = new EditorLite().createInstance({
              el: contentEl,
              blobPath: path || '',
              blobContent: content || '',
              dimensions: {
                height: contentEl.offsetHeight,
                width: contentEl.offsetWidth,
              },
            });
            this.editor.onDidChangeModelContent(debounce(this.saveDiffResolution.bind(this), 250));
          })
          .catch(() => {
            flash(__('An error occurred while loading the file'));
          });
      },
      saveDiffResolution() {
        this.saved = true;

        // This probably be better placed in the data provider
        this.file.content = this.editor.getValue();
        this.file.resolveEditChanged = this.file.content !== this.originalContent;
        this.file.promptDiscardConfirmation = false;
      },
      resetEditorContent() {
        if (this.fileLoaded) {
          this.editor.setValue(this.originalContent, -1);
        }
      },
      cancelDiscardConfirmation(file) {
        this.onCancelDiscardConfirmation(file);
      },
      acceptDiscardConfirmation(file) {
        this.onAcceptDiscardConfirmation(file);
      },
    },
  });
})(window.gl || (window.gl = {}));
