<script>
import emptySvg from '@gitlab/svgs/dist/illustrations/security-dashboard-empty-state.svg';
import { GlEmptyState } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import StepOrderApp from 'ee/vue_shared/purchase_flow/components/step_order_app.vue';
import { i18n as errorMessages } from '~/ensure_data';
import { planTags } from '../constants';
import plansQuery from '../graphql/queries/plans.query.customer.graphql';

const { ERROR_FETCHING_DATA_HEADER, ERROR_FETCHING_DATA_DESCRIPTION } = errorMessages;

export default {
  components: {
    GlEmptyState,
    StepOrderApp,
  },
  i18n: {
    ERROR_FETCHING_DATA_HEADER,
    ERROR_FETCHING_DATA_DESCRIPTION,
  },
  emptySvg,
  data() {
    return {
      plans: [],
      hasError: false,
    };
  },
  apollo: {
    plans: {
      client: 'customerClient',
      query: plansQuery,
      variables: {
        tags: [planTags.CI_1000_MINUTES_PLAN],
      },
      update(data) {
        return data.plans;
      },
      error(error) {
        this.hasError = true;
        Sentry.captureException(error);
      },
    },
  },
};
</script>
<template>
  <gl-empty-state
    v-if="hasError"
    :title="$options.i18n.ERROR_FETCHING_DATA_HEADER"
    :description="$options.i18n.ERROR_FETCHING_DATA_DESCRIPTION"
    :svg-path="`data:image/svg+xml;utf8,${encodeURIComponent($options.emptySvg)}`"
  />
  <step-order-app v-else>
    <template #checkout></template>
    <template #order-summary></template>
  </step-order-app>
</template>
