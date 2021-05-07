<script>
import { GlDeprecatedSkeletonLoading as GlSkeletonLoading, GlPopover } from '@gitlab/ui';
import { GlSingleStat } from '@gitlab/ui/dist/charts';
import Api from 'ee/api';
import createFlash from '~/flash';
import { sprintf, __, s__ } from '~/locale';
import { OVERVIEW_METRICS } from '../constants';
import { removeFlash, prepareTimeMetricsData } from '../utils';

const POPOVER_CONTENT = {
  'lead-time': {
    description: s__('ValueStreamAnalytics|Median time from issue created to issue closed.'),
  },
  'cycle-time': {
    description: s__(
      'ValueStreamAnalytics|Median time from issue first merge request created to issue closed.',
    ),
  },
  'new-issues': { description: s__('ValueStreamAnalytics|Number of new issues created.') },
  deploys: { description: s__('ValueStreamAnalytics|Total number of deploys to production.') },
  'deployment-frequency': {
    description: s__('ValueStreamAnalytics|Average number of deployments to production per day.'),
  },
};

const requestData = ({ requestType, groupPath, additionalParams }) => {
  return requestType === OVERVIEW_METRICS.TIME_SUMMARY
    ? Api.cycleAnalyticsTimeSummaryData(groupPath, additionalParams)
    : Api.cycleAnalyticsSummaryData(groupPath, additionalParams);
};

export default {
  name: 'TimeMetricsCard',
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
    additionalParams: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    requestType: {
      type: String,
      required: true,
      validator: (t) => OVERVIEW_METRICS[t],
    },
  },
  data() {
    return {
      data: [],
      loading: false,
    };
  },
  watch: {
    additionalParams() {
      this.fetchData();
    },
  },
  mounted() {
    this.fetchData();
  },
  methods: {
    fetchData() {
      removeFlash();
      this.loading = true;
      return requestData(this)
        .then(({ data }) => {
          this.data = prepareTimeMetricsData(data, POPOVER_CONTENT);
        })
        .catch(() => {
          const requestTypeName =
            this.requestType === OVERVIEW_METRICS.TIME_SUMMARY
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
        })
        .finally(() => {
          this.loading = false;
        });
    },
  },
};
</script>

<template>
  <div>
    <div v-if="loading" class="gl-h-auto gl-py-3 gl-pr-9">
      <gl-skeleton-loading />
    </div>
    <template v-else>
      <div v-for="metric in data" :key="metric.key" class="gl-pr-9">
        <gl-single-stat
          :id="metric.key"
          :value="`${metric.value}`"
          :title="metric.label"
          :unit="metric.unit || ''"
          :should-animate="true"
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
