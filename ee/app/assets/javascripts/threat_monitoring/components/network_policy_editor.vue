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
  },
  computed: {
    editorOptions() {
      return {
        lineNumbers: 'off',
        minimap: { enabled: false },
        folding: false,
        // Investigate the necessity of `glyphMargin` with #326746
        glyphMargin: false,
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
    onInput(val) {
      this.$emit('input', val);
    },
  },
};
</script>

<template>
  <editor-lite :value="value" file-name="*.yaml" :editor-options="editorOptions" @input="onInput" />
</template>
