<script>
import { GlLoadingIcon } from '@gitlab/ui';
import { __ } from '~/locale';
import getPipelineDetails from '../../graphql/queries/get_pipeline_details.query.graphql';
import LinkedPipeline from './linked_pipeline.vue';
import { UPSTREAM, DOWNSTREAM } from './constants';
import { unwrapPipelineData, visibilityToggle } from './utils';

export default {
  name: 'LinkedPipelinesColumn',
  components: {
    GlLoadingIcon,
    LinkedPipeline,
    PipelineGraph: () => import('./graph_component.vue'),
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
      // TODO: Delete this when upstream/downstream are available from backend
      currentPipelineId: null,
      currentPipeline: null,
      pipelineExpanded: false,
    }
  },
  computed: {
    columnClass() {
      const positionValues = {
        right: 'gl-ml-11',
        left: 'gl-mr-7',
      };
      return `graph-position-${this.graphPosition} ${positionValues[this.graphPosition]}`;
    },
    graphPosition() {
      return this.isUpstream ? 'left' : 'right';
    },
    isUpstream() {
      return this.type === UPSTREAM;
    },
  },
  methods: {
    isExpanded(id){
      //STUB VERSION
      return this.currentPipelineId === id;
      // return Boolean(this.currentPipeline?.id && id === this.currentPipeline.id);
    },
    onPipelineClick(pipeline, index) {

      // first, stop the polling on the current pipeline, if it exists
      // if (this.currentPipeline?.id) {
      //   this.$apollo.queries.currentPipeline.stopPolling();
      // }

      // STUB
      if (this.currentPipelineId) {
        console.log('called stop polling');
        this.$apollo.queries.currentPipeline.stopPolling();
      }

      // if the clicked pipeline has been expanded already, close it and clear
      // REAL VERSION
      // if (this.currentPipeline?.id === pipeline.id) {
      //   this.pipelineExpanded = false;
      //   this.currentPipeline = null;
      //   return;
      // }


      // STUB VERSION
      if (this.currentPipelineId === pipeline.id) {
        this.pipelineExpanded = false;
        this.currentPipeline = null;
        this.currentPipelineId = null;
        return;
      }

      // if this was not a toggle close action, and
      // this is already showing a different pipeline, then
      // this will be a no-op, but that doesn't matter

      this.pipelineExpanded = true;

      // STUB
      this.currentPipelineId = pipeline.id;


      // now let's get the data!
      // if the pipleine has been loaded before, this will return the cached value
      // otherwise it will make a request to the API
      this.$apollo.addSmartQuery('currentPipeline', {
        query: getPipelineDetails,
        pollInterval: 10000,
        variables() {
          return {
            projectPath: 'root/kinder-pipe', // pipeline.projectPath
            iid: 16, // pipeline.id
          };
        },
        update(data) {
          return unwrapPipelineData(pipeline.id, data);
        },
        error(err){
          console.error('graphQL error:', err);
        }
      })

      // finally set the check to toggle the polling status when
      // the tab is not visible because we are kind to our users
      visibilityToggle(this.$apollo.queries.currentPipeline);
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
  },
};
</script>

<template>
  <div class="gl-display-flex">
    <div :class="columnClass" class="linked-pipelines-column">
      <div class="stage-name linked-pipelines-column-title">{{ columnTitle }}</div>
      <ul>
        <li v-for="(pipeline, index) in linkedPipelines" class="gl-display-flex" :class="{'gl-flex-direction-row-reverse': isUpstream}">
          <linked-pipeline
            :key="pipeline.id"
            class="gl-display-inline-block"
            :pipeline="pipeline"
            :column-title="columnTitle"
            :type="type"
            :expanded="(isExpanded(pipeline.id))"
            @downstreamHovered="onDownstreamHovered"
            @pipelineClicked="onPipelineClick(pipeline, index)"
            @pipelineExpandToggle="onPipelineExpandToggle"
          />
          <div v-if="(isExpanded(pipeline.id))" class="gl-display-inline-block" :style="{ width: 'max-content', background: 'mistyrose'}">
            <gl-loading-icon v-if="$apollo.queries.currentPipeline.loading" class="m-auto" size="lg" />
            <pipeline-graph
              v-else
              :type="type"
              class="d-inline-block"
              :pipeline="currentPipeline"
              :is-linked-pipeline="true"
            />
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>
