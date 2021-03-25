<script>
import EditorLite from '~/vue_shared/components/editor_lite.vue';

export default {
  components: {
    EditorLite,
  },
  props: {
    value: {
      type: String,
      required: true,
    },
    readOnly: {
      type: Boolean,
      required: false,
      default: true,
    },
    height: {
      type: Number,
      required: false,
      default: 300,
    },
  },
  computed: {
    editorOptions() {
      return {
        lineNumbers: 'off',
        minimap: { enabled: false },
        folding: false,
        renderIndentGuides: false,
        renderWhitespace: 'boundary',
        renderLineHighlight: 'none',
        lineDecorationsWidth: 0,
        lineNumbersMinChars: 0,
        occurrencesHighlight: false,
        hideCursorInOverviewRuler: true,
        overviewRulerBorder: false,
        readOnly: this.readOnly,
      };
    },
  },
  methods: {
    notifyAboutUpdates() {
      this.$emit('input', this.editor.getValue());
    },
  },
};
</script>

<template>
  <editor-lite
    :value="value"
    file-name="*.yaml"
    extensions="editor_ci_schema_ext"
    :editor-options="editorOptions"
    @input="notifyAboutUpdates"
  />
</template>
