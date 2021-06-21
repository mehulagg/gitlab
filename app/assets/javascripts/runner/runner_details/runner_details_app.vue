<script>
import createFlash from '~/flash';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import { s__ } from '~/locale';
import RunnerTypeAlert from '../components/runner_type_alert.vue';
import RunnerTypeBadge from '../components/runner_type_badge.vue';
import RunnerUpdateForm from '../components/runner_update_form.vue';
import { I18N_DETAILS_TITLE, RUNNER_ENTITY_TYPE } from '../constants';
import getRunnerQuery from '../graphql/get_runner.query.graphql';
import { reportToSentry } from '../sentry_utils';

export default {
  components: {
    RunnerTypeAlert,
    RunnerTypeBadge,
    RunnerUpdateForm,
  },
  i18n: {
    I18N_DETAILS_TITLE,
  },
  props: {
    runnerId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      runner: undefined,
    };
  },
  apollo: {
    runner: {
      query: getRunnerQuery,
      variables() {
        return {
          id: convertToGraphQLId(RUNNER_ENTITY_TYPE, this.runnerId),
        };
      },
      error(error) {
        createFlash({ message: s__('Runners|Something went wrong while fetching runner data.') });

        this.reportError(error);
      },
    },
  },
  errorCaptured(error) {
    this.reportError(error);
  },
  methods: {
    reportError(error) {
      reportToSentry({ error, component: 'runner_details_app' });
    },
  },
};
</script>
<template>
  <div>
    <h2 class="page-title">
      {{ sprintf($options.i18n.I18N_DETAILS_TITLE, { runner_id: runnerId }) }}

      <runner-type-badge v-if="runner" :type="runner.runnerType" />
    </h2>

    <runner-type-alert v-if="runner" :type="runner.runnerType" />

    <runner-update-form :runner="runner" class="gl-my-5" />
  </div>
</template>
