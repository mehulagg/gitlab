<script>
import { GlLoadingIcon } from '@gitlab/ui';
import getPipelineDetails from '../../graphql/queries/get_pipeline_details.query.graphql';
import PipelineGraph from './graph_component.vue';
import { unwrapPipelineData } from './utils';

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
};
</script>
<template>
  <gl-loading-icon v-if="$apollo.queries.pipeline.loading" class="m-auto" size="lg" />
  <pipeline-graph
    v-else
    :pipeline="pipeline"
  />
</template>
