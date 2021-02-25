<script>
import PipelineStage from '~/pipelines/components/pipelines_list/pipeline_stage.vue';
/**
 * Renders the pipeline mini graph.
 */
export default {
  components: {
    PipelineStage,
  },
  props: {
    stages: {
      type: Array,
      required: false,
      default: () => [],
    },
    stagesClass: {
      type: [Array, Object, String],
      required: false,
      default: '',
    },
  },
  methods: {
    onPipelineActionRequestComplete() {
      this.$emit('pipelineActionRequestComplete');
    },
  },
};
</script>
<template>
  <div v-if="stages && stages.length" data-testid="widget-mini-pipeline-graph">
    <div
      v-for="(stage, i) in stages"
      :key="i"
      :class="stagesClass"
      class="stage-container dropdown"
    >
      <pipeline-stage
        :stage="stage"
        @pipelineActionRequestComplete="onPipelineActionRequestComplete"
      />
    </div>
  </div>
</template>
