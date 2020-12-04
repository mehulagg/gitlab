<script>
import EditorLite from '~/vue_shared/components/editor_lite.vue';
import ciConfigExtension from '~/editor/editor_ci_config_ext';

export default {
  components: {
    EditorLite,
  },
  props: {
    // TODO Use provide/inject
    projectPath: {
      type: String,
      required: true,
    },
  },
  methods: {
    editorReady(editor) {
      const [namespace, project] = this.projectPath.split('/');

      editor.use(ciConfigExtension);
      editor.registerCiSchema({
        namespace,
        project,
      });
    },
  },
};
</script>
<template>
  <div class="gl-border-solid gl-border-gray-100 gl-border-1">
    <editor-lite file-name="*.yml" v-bind="$attrs" v-on="$listeners" @editor-ready="editorReady" />
  </div>
</template>
