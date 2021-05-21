<script>
import { GlDeprecatedSkeletonLoading as GlSkeletonLoading, GlPopover } from '@gitlab/ui';
import { GlSingleStat } from '@gitlab/ui/dist/charts';
import Api from 'ee/api';
import createFlash from '~/flash';
import { sprintf, __, s__ } from '~/locale';
import { OVERVIEW_METRICS, METRICS_POPOVER_CONTENT } from '../constants';
import { removeFlash, prepareTimeMetricsData } from '../utils';

const requestData = ({ requestType, groupPath, requestParams }) => {
  return requestType === OVERVIEW_METRICS.TIME_SUMMARY
    ? Api.cycleAnalyticsTimeSummaryData(groupPath, requestParams)
    : Api.cycleAnalyticsSummaryData(groupPath, requestParams);
};

export default {
  name: 'OverviewActivity',
  components: {
    GlSkeletonLoading,
    GlSingleStat,
    GlPopover,
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
  data() {
    return {
      metrics: [],
      isLoading: false,
    };
  },
  watch: {
    requestParams() {
      this.fetchData();
    },
  },
  mounted() {
    this.fetchData();
  },
  methods: {
    fetchData() {
      removeFlash();
      this.isLoading = true;

      Promise.all([
        this.fetchMetricsByType(OVERVIEW_METRICS.TIME_SUMMARY),
        this.fetchMetricsByType(OVERVIEW_METRICS.RECENT_ACTIVITY),
      ])
        .then(([timeSummaryData = [], recentActivityData = []]) => {
          this.metrics = [
            ...prepareTimeMetricsData(timeSummaryData, METRICS_POPOVER_CONTENT),
            ...prepareTimeMetricsData(recentActivityData, METRICS_POPOVER_CONTENT),
          ];
          this.isLoading = false;
        })
        .catch(() => {
          this.isLoading = false;
        });
    },
    fetchMetricsByType(requestType) {
      return requestData({
        requestType,
        groupPath: this.groupPath,
        requestParams: this.requestParams,
      })
        .then(({ data }) => data)
        .catch(() => {
          const requestTypeName =
            requestType === OVERVIEW_METRICS.TIME_SUMMARY
              ? __('time summary')
              : __('recent activity');
          createFlash({
            message: sprintf(
              s__(
                'There was an error while fetching value stream analytics %{requestTypeName} data.',
              ),
              { requestTypeName },
            ),
          });
        });
    },
  },
};
</script>
<template>
  <div class="gl-display-flex gl-flex-wrap" data-testid="vsa-time-metrics">
    <div v-if="isLoading" class="gl-h-auto gl-py-3 gl-pr-9 gl-my-6">
      <gl-skeleton-loading />
    </div>
    <template v-else>
      <div v-for="metric in metrics" :key="metric.key" class="gl-my-6 gl-pr-9">
        <gl-single-stat
          :id="metric.key"
          :value="`${metric.value}`"
          :title="metric.label"
          :unit="metric.unit || ''"
          :should-animate="true"
          :animation-decimal-places="1"
          tabindex="0"
        />
        <gl-popover :target="metric.key" placement="bottom">
          <template #title>
            <span class="gl-display-block gl-text-left">{{ metric.label }}</span>
          </template>

          <span v-if="metric.description">{{ metric.description }}</span>
        </gl-popover>
      </div>
    </template>
  </div>
</template>
