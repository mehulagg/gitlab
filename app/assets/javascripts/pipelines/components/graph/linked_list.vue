<script>
import getPipelineDetails from 'shared_queries/pipelines/get_pipeline_details.query.graphql';
import { GlButton } from '@gitlab/ui';
import { LOAD_FAILURE } from '../../constants';
import { ONE_COL_WIDTH, UPSTREAM } from './constants';
import PipelineList from './graph_list.vue';
import {
  getQueryHeaders,
  reportToSentry,
  toggleQueryPollingByVisibility,
  unwrapPipelineData,
  validateConfigPaths,
} from './utils';

export default {
  components: {
    GlButton,
    PipelineList: () => import('./graph_list.vue'),
  },
  props: {
    columnTitle: {
      type: String,
      required: true,
    },
    linkedPipelines: {
      type: Array,
      required: true,
    },
    type: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      currentPipeline: null,
      loadingPipelineId: null,
      pipelineExpanded: false,
    };
  },
  titleClasses: [
    'gl-font-weight-bold',
    'gl-pipeline-job-width',
    'gl-text-truncate',
    'gl-line-height-36',
    'gl-pl-3',
    'gl-mb-5',
  ],
  minWidth: `${ONE_COL_WIDTH}px`,
  computed: {
    columnClass() {
      const positionValues = {
        right: 'gl-ml-6',
        left: 'gl-mr-6',
      };
      return `graph-position-${this.graphPosition} ${positionValues[this.graphPosition]}`;
    },
    computedTitleClasses() {
      const positionalClasses = this.isUpstream
        ? ['gl-w-full', 'gl-text-right', 'gl-linked-pipeline-padding']
        : [];

      return [...this.$options.titleClasses, ...positionalClasses];
    },
    expandButtonPosition() {
      return this.isUpstream ? 'gl-left-0 gl-border-r-1!' : 'gl-right-0 gl-border-l-1!';
    },
    expandedIcon() {
      if (this.isUpstream) {
        return this.pipelineExpanded ? 'angle-right' : 'angle-left';
      }
      return this.pipelineExpanded ? 'angle-left' : 'angle-right';
    },
    graphPosition() {
      return this.isUpstream ? 'left' : 'right';
    },
    isUpstream() {
      return this.type === UPSTREAM;
    },
    minWidth() {
      return this.isUpstream ? 0 : this.$options.minWidth;
    },
  },
  methods: {
    getPipelineData(pipeline) {
      const projectPath = pipeline.project.fullPath;

      this.$apollo.addSmartQuery('currentPipeline', {
        query: getPipelineDetails,
        pollInterval: 10000,
        variables() {
          return {
            projectPath,
            iid: pipeline.iid,
          };
        },
        update(data) {
          return unwrapPipelineData(projectPath, data);
        },
        result() {
          this.loadingPipelineId = null;
          this.$emit('scrollContainer');
        },
        error(err, _vm, _key, type) {
          this.$emit('error', LOAD_FAILURE);

          reportToSentry(
            'linked_pipelines_column',
            `error type: ${LOAD_FAILURE}, error: ${err}, apollo error type: ${type}`,
          );
        },
      });

      toggleQueryPollingByVisibility(this.$apollo.queries.currentPipeline);
    },
    isExpanded(id) {
      return Boolean(this.currentPipeline?.id && id === this.currentPipeline.id);
    },
    isLoadingPipeline(id) {
      return this.loadingPipelineId === id;
    },
    getHeadline(pipeline){
      const pipelineName = pipeline.project.name || 'child pipeline';
      return this.isUpstream
        ? pipeline.project.name
        : `${pipelineName} • source: ${pipeline.sourceJob.name}`;
    },
    getSource(pipeline) {
      return pipeline.sourceJob?.name || 'n/a';
    },
    onPipelineClick(pipeline) {
      /* If the clicked pipeline has been expanded already, close it, clear, exit */
      if (this.currentPipeline?.id === pipeline.id) {
        this.pipelineExpanded = false;
        this.currentPipeline = null;
        return;
      }

      /* Set the loading id */
      this.loadingPipelineId = pipeline.id;

      /*
        Expand the pipeline.
        If this was not a toggle close action, and
        it was already showing a different pipeline, then
        this will be a no-op, but that doesn't matter.
      */
      this.pipelineExpanded = true;

      this.getPipelineData(pipeline);
    },
    onDownstreamHovered(jobName) {
      this.$emit('downstreamHovered', jobName);
    },
    onPipelineExpandToggle(jobName, expanded) {
      // Highlighting only applies to downstream pipelines
      if (this.isUpstream) {
        return;
      }

      this.$emit('pipelineExpandToggle', jobName, expanded);
    },
    showContainer(id) {
      return this.isExpanded(id) || this.isLoadingPipeline(id);
    },
  },
};
</script>

<template>
  <div>
    <h3 class="gl-mt-11"> {{ columnTitle }} </h3>
    <hr />
    <div v-for="pipeline in linkedPipelines">
      <h4> {{ getHeadline(pipeline) }}
        <gl-button
          class="gl-shadow-none! gl-rounded-0!"
          :class="`js-pipeline-expand-${pipeline.id} ${expandButtonPosition}`"
          :icon="expandedIcon"
          @click="onPipelineClick(pipeline)"
        />
      </h4>
      <div
        v-if="showContainer(pipeline.id)"
      >
        <pipeline-list
          v-if="isExpanded(pipeline.id)"
          class="gl-ml-5"
          :type="type"
          :pipeline="currentPipeline"
          :is-linked-pipeline="true"
        />
      </div>
    </div>
  </div>
</template>
