<script>
import { GlLoadingIcon } from '@gitlab/ui';
import getPipelineDetails from '../../graphql/queries/get_pipeline_details.query.graphql';
import PipelineGraph from './graph_component.vue';
import { unwrapPipelineData, visibilityToggle } from './utils';

export default {
  name: 'PipelineGraphWrapper',
  components: {
    PipelineGraph,
    GlLoadingIcon,
  },
  inject: {
    pipelineIid: {
      default: '',
    },
    pipelineProjectPath: {
      default: '',
    },
  },
  data() {
    return {
      pipeline: null,
    };
  },
  apollo: {
    pipeline: {
      query: getPipelineDetails,
      pollInterval: 10000,
      variables() {
        return {
          projectPath: this.pipelineProjectPath,
          iid: this.pipelineIid,
        };
      },
      update(data) {
        return unwrapPipelineData(this.pipelineIid, data);
      },
      error(err){
        console.error('graphQL error:', err);
      }
    }
  },
  mounted() {
    // This sets the watchers to stop and start polling
    // based on the tab visibility 
    visibilityToggle(this.$apollo.queries.pipeline);
  }
};
</script>
<template>
  <gl-loading-icon v-if="$apollo.queries.pipeline.loading" class="m-auto" size="lg" />
  <pipeline-graph
    v-else
    :pipeline="pipeline"
  />
</template>
