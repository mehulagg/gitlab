<script>
import { OVERVIEW_METRICS } from '../constants';
import TimeMetricsCard from './time_metrics_card.vue';

export default {
  name: 'OverviewActivity',
  components: {
    TimeMetricsCard,
  },
  props: {
    groupPath: {
      type: String,
      required: true,
    },
    requestParams: {
      type: Object,
      required: true,
    },
  },
  overviewMetrics: OVERVIEW_METRICS,
};
</script>
<template>
  <div class="gl-display-flex gl-sm-flex-direction-column" data-testid="vsa-time-metrics">
    <time-metrics-card
      class="gl-display-flex gl-my-6"
      :group-path="groupPath"
      :additional-params="requestParams"
      :request-type="$options.overviewMetrics.TIME_SUMMARY"
    />
    <time-metrics-card
      class="gl-display-flex gl-my-6"
      :group-path="groupPath"
      :additional-params="requestParams"
      :request-type="$options.overviewMetrics.RECENT_ACTIVITY"
    />
  </div>
</template>
