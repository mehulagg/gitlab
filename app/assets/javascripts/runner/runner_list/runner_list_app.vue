<script>
import * as Sentry from '@sentry/browser';
import RunnerFilteredSearchBar from '../components/runner_filtered_search_bar.vue';
import RunnerList from '../components/runner_list.vue';
import RunnerManualSetupHelp from '../components/runner_manual_setup_help.vue';
import RunnerTypeHelp from '../components/runner_type_help.vue';
import getRunnersQuery from '../graphql/get_runners.query.graphql';

export default {
  components: {
    RunnerFilteredSearchBar,
    RunnerList,
    RunnerManualSetupHelp,
    RunnerTypeHelp,
  },
  props: {
    activeRunnersCount: {
      type: Number,
      required: true,
    },
    registrationToken: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      // TODO Set the inital state from the URL
      filterParameters: {},
      runners: [],
    };
  },
  apollo: {
    runners: {
      query: getRunnersQuery,
      variables() {
        return this.filterParameters;
      },
      update({ runners }) {
        return runners?.nodes || [];
      },
      error(err) {
        this.captureException(err);
      },
    },
  },
  computed: {
    runnersLoading() {
      return this.$apollo.queries.runners.loading;
    },
  },
  errorCaptured(err) {
    this.captureException(err);
  },
  methods: {
    captureException(err) {
      Sentry.withScope((scope) => {
        scope.setTag('component', 'runner_list_app');
        Sentry.captureException(err);
      });
    },
    onFilter(newFilterParameters) {
      this.filterParameters = newFilterParameters;
    },
  },
};
</script>
<template>
  <div>
    <div class="row">
      <div class="col-sm-6">
        <runner-type-help />
      </div>
      <div class="col-sm-6">
        <runner-manual-setup-help :registration-token="registrationToken" />
      </div>
    </div>

    <runner-filtered-search-bar namespace="admin_runners" @onFilter="onFilter" />

    <div v-if="!runnersLoading && !runners.length" class="gl-text-center gl-p-5">
      {{ __('No runners found') }}
    </div>
    <runner-list
      v-else
      :runners="runners"
      :loading="runnersLoading"
      :active-runners-count="activeRunnersCount"
    />
  </div>
</template>
