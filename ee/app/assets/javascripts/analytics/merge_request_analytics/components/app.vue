<script>
import { getDateInPast } from '~/lib/utils/datetime_utility';
import { DEFAULT_NUMBER_OF_DAYS } from '../constants';
import ThroughputChart from './throughput_chart.vue';
import ThroughputTable from './throughput_table.vue';

export default {
  name: 'MergeRequestAnalyticsApp',
  components: {
    ThroughputChart,
    ThroughputTable,
  },
  data() {
    return {
      startDate: getDateInPast(new Date(), DEFAULT_NUMBER_OF_DAYS),
      endDate: new Date(),
    };
  },

  emits: [],
};
</script>
<template>
  <div class="merge-request-analytics-wrapper">
    <h3 data-testid="pageTitle" class="gl-mb-5">{{ __('Merge Request Analytics') }}</h3>
    <throughput-chart :start-date="startDate" :end-date="endDate" />
    <throughput-table :start-date="startDate" :end-date="endDate" class="gl-mt-6" />
  </div>
</template>
