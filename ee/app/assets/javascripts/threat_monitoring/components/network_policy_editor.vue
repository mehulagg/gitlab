<script>
import { editor as monacoEditor } from 'monaco-editor';

export default {
  props: {
    value: {
      type: String,
      required: true,
    },
  },
  data() {
    return { editor: null };
  },
  watch: {
    value(val) {
      if (val === this.editor.getValue()) return;
      this.editor.setValue(val);
    },
  },
  beforeDestroy() {
    this.editor.dispose();
  },
  mounted() {
    if (!this.editor) {
      this.setupEditor();
    }
  },
  methods: {
    setupEditor() {
      this.editor = monacoEditor.create(this.$refs.editor, {
        value: this.value,
        language: 'yaml',
        lineNumbers: 'off',
        minimap: { enabled: false },
        folding: false,
        renderIndentGuides: false,
        renderWhitespace: 'boundary',
        renderLineHighlight: 'none',
        glyphMargin: false,
        lineDecorationsWidth: 0,
        lineNumbersMinChars: 0,
        occurrencesHighlight: false,
        hideCursorInOverviewRuler: true,
        overviewRulerBorder: false,
        readOnly: true,
      });
      this.editor.onDidChangeModelContent(() => {
        this.$emit('input', this.editor.getValue());
      });
    },
  },

  emits: ['input'],
};
</script>

<template>
  <div
    ref="editor"
    class="multi-file-editor-holer network-policy-editor gl-bg-gray-50 p-2 gl-overflow-x-hidden"
  ></div>
</template>
