<script>
import getPipelineCountByStatus from '../graphql/queries/get_pipeline_count_by_status.query.graphql';

export default {
  inject: {
    projectPath: {
      type: String,
      default: '',
    },
  },
  data() {
    return {
      count: {},
    };
  },
  apollo: {
    count: {
      query: getPipelineCountByStatus,
      variables() {
        return {
          pipelineStatus: 'SUCCESS',
          projectPath: this.projectPath,
        };
      },
      update(res) {
        return res;
      },
    },
  },
};
</script>
<template>
  <div>
    {{ count }}
  </div>
</template>
