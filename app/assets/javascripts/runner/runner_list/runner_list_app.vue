<script>
import RunnerDescription from '../components/runner_description.vue';
import RunnerList from '../components/runner_list.vue';
import RunnerManualSetupHelp from '../components/runner_manual_setup_help.vue';
import getRunnersQuery from '../graphql/get_runners.query.graphql';

export default {
  components: {
    RunnerDescription,
    RunnerList,
    RunnerManualSetupHelp,
  },
  props: {
    registrationToken: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      runners: [],
    };
  },
  apollo: {
    runners: {
      query: getRunnersQuery,
      update({ runners }) {
        return runners.nodes;
      },
    },
  },
};
</script>
<template>
  <div>
    <div class="row">
      <div class="col-sm-6">
        <runner-description />
      </div>
      <div class="col-sm-6">
        <runner-manual-setup-help :registration-token="registrationToken" />
      </div>
    </div>

    <!-- TODO Add an empty state for no runners -->
    <runner-list :runners="runners" />
  </div>
</template>
