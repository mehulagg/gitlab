<script>
import { GlAlert } from '@gitlab/ui';
import { __ } from '~/locale';
import LinkedGraphWrapper from '../graph_shared/linked_graph_wrapper.vue';
import LinksLayer from '../graph_shared/links_layer.vue';
import LinkedPipelinesColumn from './linked_pipelines_column.vue';
import StageColumnComponent from './stage_column_component.vue';
import { DOWNSTREAM, MAIN, UPSTREAM } from './constants';

export default {
  name: 'PipelineGraph',
  components: {
    GlAlert,
    LinksLayer,
    LinkedGraphWrapper,
    LinkedPipelinesColumn,
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
  pipelineTypeConstants: {
    DOWNSTREAM,
    UPSTREAM,
  },
  CONTAINER_REF: 'PIPELINE_LINKS_CONTAINER_REF',
  CONTAINER_ID: 'pipeline-links-container',
  MAX_STAGES: 1000,
  data() {
    return {
      alertDismissed: false,
      hoveredJobName: '',
      pipelineExpanded: {
        jobName: '',
        expanded: false,
      },
      showLinksOverride: false,
    };
  },
  i18n: {
    showLinksAnyways: __('Show links anyways'),
    tooManyStages: __('This graph has a large number of stages and showing the links may be slow.')
  },
  computed: {
    downstreamPipelines() {
      return this.hasDownstreamPipelines ? this.pipeline.downstream : [];
    },
    graph() {
      return this.pipeline.stages;
    },
    hasDownstreamPipelines() {
      return Boolean(this.pipeline?.downstream?.length > 0);
    },
    hasUpstreamPipelines() {
      return Boolean(this.pipeline?.upstream?.length > 0);
    },
    linkWrapper() {
      return this.showLinkedLayers || this.showLinksOverride  ? 'links-layer' : 'div';
    },
    numStages() {
      return this.graph.reduce((acc, { groups }) => {
        return acc + Number(groups.length)
      }, 0)
    },
    showAlert() {
      return !this.showLinkedLayers && !this.alertDismissed;
    },
    // The show downstream check prevents showing redundant linked columns
    showDownstreamPipelines() {
      return (
        this.hasDownstreamPipelines && this.type !== this.$options.pipelineTypeConstants.UPSTREAM
      );
    },
    showLinkedLayers() {
      return this.numStages < this.$options.MAX_STAGES;
    },
    // The show upstream check prevents showing redundant linked columns
    showUpstreamPipelines() {
      return (
        this.hasUpstreamPipelines && this.type !== this.$options.pipelineTypeConstants.DOWNSTREAM
      );
    },
    upstreamPipelines() {
      return this.hasUpstreamPipelines ? this.pipeline.upstream : [];
    },
  },
  methods: {
    dismissAlert() {
      this.alertDismissed = true;
    },
    overrideShowLinks() {
      this.dismissAlert();
      this.showLinksOverride = true;
    },
    setJob(jobName) {
      this.hoveredJobName = jobName;
    },
    togglePipelineExpanded(jobName, expanded) {
      this.pipelineExpanded = {
        expanded,
        jobName: expanded ? jobName : '',
      };
    },
  },
};
</script>
<template>
  <div class="js-pipeline-graph">
    <gl-alert
      v-if="showAlert"
      :primary-button-text="$options.i18n.showLinksAnyways"
      @primaryAction="overrideShowLinks"
      @dismiss="dismissAlert"
    >
      {{ $options.i18n.tooManyStages }}
    </gl-alert>
    <div
      class="gl-pipeline-min-h gl-display-flex gl-position-relative gl-overflow-auto gl-bg-gray-10 gl-white-space-nowrap"
      :class="{ 'gl-py-5': !isLinkedPipeline }"
      :id="$options.CONTAINER_ID"
      :ref="$options.CONTAINER_REF"
    >
      <component :is='linkWrapper'
        :pipeline-data="graph"
        :container-id="$options.CONTAINER_ID"
        :container-ref="$options.CONTAINER_REF"
        :highlighted-job="hoveredJobName"
        default-link-color="gl-stroke-transparent"
      >
        <linked-graph-wrapper>
          <template #upstream>
            <linked-pipelines-column
              v-if="showUpstreamPipelines"
              :linked-pipelines="upstreamPipelines"
              :column-title="__('Upstream')"
              :type="$options.pipelineTypeConstants.UPSTREAM"
              @error="emit('error', errorType)"
            />
          </template>
          <template #main>
            <stage-column-component
              v-for="stage in graph"
              :key="stage.name"
              :title="stage.name"
              :groups="stage.groups"
              :action="stage.status.action"
              :job-hovered="hoveredJobName"
              :pipeline-expanded="pipelineExpanded"
              @refreshPipelineGraph="$emit('refreshPipelineGraph')"
              @jobHover="setJob"
            />
          </template>
          <template #downstream>
            <linked-pipelines-column
              v-if="showDownstreamPipelines"
              :linked-pipelines="downstreamPipelines"
              :column-title="__('Downstream')"
              :type="$options.pipelineTypeConstants.DOWNSTREAM"
              @downstreamHovered="setJob"
              @pipelineExpandToggle="togglePipelineExpanded"
              @error="emit('error', errorType)"
            />
          </template>
        </linked-graph-wrapper>
      </component>
    </div>
  </div>
</template>
