<script>
/* eslint-disable vue/no-v-html */
import { HIGHLIGHT_CLASS_NAME } from './constants';
import ViewerMixin from './mixins';
import { debounce } from 'lodash';
import { initEditorLite } from '~/blob/utils';
import { SNIPPET_MEASURE_BLOBS_CONTENT } from '~/performance/constants';

export default {
  mixins: [ViewerMixin],
  props: {
    value: {
      type: String,
      required: false,
      default: '',
    },
    fileName: {
      type: String,
      required: false,
      default: '',
    },
    editable: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      highlightedLine: null,
    };
  },
  computed: {
    lineNumbers() {
      return this.content.split('\n').length;
    },
  },
  watch: {
    fileName(newVal) {
      this.editor.updateModelLanguage(newVal);
    },
  },
  mounted() {
    this.editor = initEditorLite({
      el: this.$refs.editor,
      blobPath: this.fileName,
      blobContent: this.content,
      blobGlobalId: 'DEF',
      readOnly: !this.editable,
    });

    this.editor.onDidChangeModelContent(debounce(this.onFileChange.bind(this), 250));

    // eventHub.$emit(SNIPPET_MEASURE_BLOBS_CONTENT);

    const { hash } = window.location;
    if (hash) this.scrollToLine(hash, true);
  },
  methods: {
    scrollToLine(hash, scroll = false) {
      const lineToHighlight = hash && this.$el.querySelector(hash);
      const currentlyHighlighted = this.highlightedLine;
      if (lineToHighlight) {
        if (currentlyHighlighted) {
          currentlyHighlighted.classList.remove(HIGHLIGHT_CLASS_NAME);
        }

        lineToHighlight.classList.add(HIGHLIGHT_CLASS_NAME);
        this.highlightedLine = lineToHighlight;
        if (scroll) {
          lineToHighlight.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
      }
    },
    onFileChange() {
      this.$emit('input', this.editor.getValue());
    },
  },
  userColorScheme: window.gon.user_color_scheme,
};
</script>
<template>
  <div class="file-editor code">
    <div id="editor" ref="editor" data-editor-loading>
      <pre class="editor-loading-content">{{ content }}</pre>
    </div>
  </div>
</template>
