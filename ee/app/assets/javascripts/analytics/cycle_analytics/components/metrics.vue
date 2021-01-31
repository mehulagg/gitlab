<script>
import MetricCard from '~/analytics/shared/components/metric_card.vue';
import { OVERVIEW_METRICS } from '../constants';
import TimeMetricsCard from './time_metrics_card.vue';

export default {
  name: 'OverviewActivity',
  components: {
    TimeMetricsCard,
    MetricCard,
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
  <div class="js-recent-activity gl-mt-3 gl-display-flex">
    <div class="gl-flex-fill-1 gl-pr-2">
      <time-metrics-card
        #default="{ metrics, loading }"
        :group-path="groupPath"
        :additional-params="requestParams"
        :request-type="$options.overviewMetrics.TIME_SUMMARY"
      >
        <metric-card :title="__('Time')" :metrics="metrics" :is-loading="loading" />
      </time-metrics-card>
    </div>
    <div class="gl-flex-fill-1 gl-pl-2">
      <time-metrics-card
        #default="{ metrics, loading }"
        :group-path="groupPath"
        :additional-params="requestParams"
        :request-type="$options.overviewMetrics.RECENT_ACTIVITY"
      >
        <metric-card :title="__('Recent Activity')" :metrics="metrics" :is-loading="loading" />
      </time-metrics-card>
    </div>
  </div>
</template>
