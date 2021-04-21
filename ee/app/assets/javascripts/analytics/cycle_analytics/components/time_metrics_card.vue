<script>
import { GlDeprecatedSkeletonLoading as GlSkeletonLoading } from '@gitlab/ui';
import { GlSingleStat } from '@gitlab/ui/dist/charts';
import Api from 'ee/api';
import createFlash from '~/flash';
import { sprintf, __, s__ } from '~/locale';
import { OVERVIEW_METRICS } from '../constants';
import { removeFlash, prepareTimeMetricsData } from '../utils';

const I18N_TEXT = {
  'lead-time': s__('ValueStreamAnalytics|Median time from issue created to issue closed.'),
  'cycle-time': s__('ValueStreamAnalytics|Median time from first commit to issue closed.'),
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
          this.data = prepareTimeMetricsData(data, I18N_TEXT);
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
  <gl-skeleton-loading v-if="loading" class="gl-h-auto gl-py-3 gl-pr-6" />
  <div v-else>
    <gl-single-stat
      v-for="metric in data"
      :key="metric.key"
      class="gl-pr-6"
      :value="metric.value"
      :title="metric.label"
      :unit="metric.unit || ''"
      :should-animate="true"
    />
  </div>
</template>
