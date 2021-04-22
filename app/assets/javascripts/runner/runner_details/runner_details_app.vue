<script>
import RunnerTypeBadge from '../components/runner_type_badge.vue';
import getRunnerQuery from '../graphql/get_runner.query.graphql';
import { I18N_TITLE } from './constants';

export default {
  components: {
    RunnerTypeBadge,
  },
  i18n: {
    I18N_TITLE,
  },
  props: {
    runnerId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      runner: {},
    };
  },
  apollo: {
    runner: {
      query: getRunnerQuery,
      variables() {
        return {
          id: this.runnerId,
        };
      },
      update({ runner }) {
        return runner;
      },
    },
  },
};
</script>
<template>
  <h2 class="page-title">
    {{ sprintf($options.i18n.I18N_TITLE, { runner_id: runnerId }) }}

    <runner-type-badge v-if="runner.runnerType" :type="runner.runnerType" />
  </h2>
</template>
