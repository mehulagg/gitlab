<script>
import EditorLite from '~/vue_shared/components/editor_lite.vue';
import { CiSchemaExtension } from '~/editor/extensions/editor_ci_schema_ext';
import getCommitSha from '../graphql/queries/client/commit_sha.graphql';

export default {
  components: {
    EditorLite,
  },
  inject: ['ciConfigPath', 'projectPath', 'projectNamespace'],
  inheritAttrs: false,
  data() {
    return {
      commitSha: '',
    };
  },
  apollo: {
    commitSha: {
      query: getCommitSha,
    },
  },
  methods: {
    onCiConfigUpdate(content) {
      this.$emit('updateCiConfig', content);
    },
    onEditorReady() {
      const editorInstance = this.$refs.editor.getEditor();

      editorInstance.use(new CiSchemaExtension());
      editorInstance.registerCiSchema({
        projectPath: this.projectPath,
        projectNamespace: this.projectNamespace,
        ref: this.commitSha,
      });
    },
  },
};
</script>
<template>
  <div class="gl-border-solid gl-border-gray-100 gl-border-1">
    <editor-lite
      ref="editor"
      :file-name="ciConfigPath"
      v-bind="$attrs"
      @input="onCiConfigUpdate"
      @editor-ready="onEditorReady"
      v-on="$listeners"
    />
  </div>
</template>
