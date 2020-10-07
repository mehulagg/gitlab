<script>
import dateFormat from 'dateformat';
import UrlSync from '~/vue_shared/components/url_sync.vue';
import { getDateInPast } from '~/lib/utils/datetime_utility';
import DateRange from '../../shared/components/daterange.vue';
import { dateFormats } from '../../shared/constants';
import { DEFAULT_NUMBER_OF_DAYS } from '../constants';
import FilterBar from './filter_bar.vue';
import ThroughputChart from './throughput_chart.vue';
import ThroughputTable from './throughput_table.vue';

export default {
  name: 'MergeRequestAnalyticsApp',
  components: {
    DateRange,
    FilterBar,
    ThroughputChart,
    ThroughputTable,
    UrlSync,
  },
  data() {
    return {
      startDate: getDateInPast(new Date(), DEFAULT_NUMBER_OF_DAYS),
      endDate: new Date(),
    };
  },
  computed: {
    query() {
      return {
        start_date: dateFormat(this.startDate, dateFormats.isoDate),
        end_date: dateFormat(this.endDate, dateFormats.isoDate),
      };
    },
  },
  methods: {
    setDateRange({ startDate, endDate }) {
      this.startDate = startDate;
      this.endDate = endDate;
    },
  },
};
</script>
<template>
  <div class="merge-request-analytics-wrapper">
    <h3 data-testid="pageTitle" class="gl-mb-5">{{ __('Merge Request Analytics') }}</h3>
    <div
      class="gl-display-flex gl-flex-direction-column gl-lg-flex-direction-row gl-justify-content-space-between gl-bg-gray-10 gl-border-t-solid gl-border-t-1 gl-border-t-gray-100 gl-border-b-solid gl-border-b-1 gl-border-b-gray-100 gl-py-3"
    >
      <filter-bar class="gl-flex-grow-1 gl-lg-ml-3" />
      <date-range
        :start-date="startDate"
        :end-date="endDate"
        class="gl-lg-mx-3"
        @change="setDateRange"
      />
    </div>
    <throughput-chart :start-date="startDate" :end-date="endDate" />
    <throughput-table :start-date="startDate" :end-date="endDate" class="gl-mt-6" />
    <url-sync :query="query" />
  </div>
</template>
