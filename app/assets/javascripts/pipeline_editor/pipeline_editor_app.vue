<script>
import Api from '~/api';
import PipelineTextEditor from './components/pipeline_text_editor.vue';

export default {
  components: {
    PipelineTextEditor,
  },
  props: {
    projectId: {
      type: String,
      required: true,
    },
    ciConfigPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      content: '',
    };
  },
  mounted() {
    Api.getRawFile(this.projectId, this.ciConfigPath)
      .then(({ data }) => {
        this.content = data;
      })
      .catch(() => {
        // TODO
      });
  },
};
</script>

<template>
  <div>
    <pipeline-text-editor v-model="content" />
  </div>
</template>
