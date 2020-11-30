<script>
import LinkedGraphWrapper from '../graph_shared/linked_graph_wrapper.vue';
import StageColumnComponent from './stage_column_component.vue';
import { MAIN } from './constants';

export default {
  name: 'PipelineGraph',
  components: {
    LinkedGraphWrapper,
    StageColumnComponent,
  },
  props: {
    isLinkedPipeline: {
      type: Boolean,
      required: false,
      default: false,
    },
    pipeline: {
      type: Object,
      required: true,
    },
    type: {
      type: String,
      required: false,
      default: MAIN,
    },
  },
  computed: {
    graph() {
      return this.pipeline.stages;
    },
  },
};
</script>
<template>
  <div class="js-pipeline-graph">
    <div
      class="gl-pipeline-min-h gl-display-flex gl-position-relative gl-overflow-auto gl-bg-gray-10 gl-white-space-nowrap"
      :class="{ 'gl-py-5': !isLinkedPipeline }"
    >
      <linked-graph-wrapper>
        <template #upstream>
          <linked-pipelines-column
            v-if="showUpstreamPipelines"
            :linked-pipelines="upstreamPipelines"
            :column-title="__('Upstream')"
            :type="$options.pipelineTypeConstants.UPSTREAM"
          />
        </template>
        <template #main>
          <stage-column-component
            v-for="stage in graph"
            :key="stage.name"
            :title="stage.name"
            :groups="stage.groups"
            :action="stage.status.action"
          />
        </template>
        <template #downstream>
          <linked-pipelines-column
            v-if="showDownstreamPipelines"
            :linked-pipelines="downstreamPipelines"
            :column-title="__('Downstream')"
            :type="$options.pipelineTypeConstants.DOWNSTREAM"
            @downstreamHovered="setJob"
            @pipelineExpandToggle="setPipelineExpanded"
          />
        </template>
      </linked-graph-wrapper>
    </div>
  </div>
</template>
