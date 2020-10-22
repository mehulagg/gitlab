<script>
import { GlLineChart } from '@gitlab/ui/dist/charts';
import { GlAlert } from '@gitlab/ui';
import { some } from 'lodash';
import { produce } from 'immer';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import { differenceInMonths, formatDateAsMonth } from '~/lib/utils/datetime_utility';
import { getAverageByMonth } from '../utils';
import { TODAY, START_DATE } from '../constants';

export default {
  name: 'InstanceStatisticsCountChart',
  components: {
    GlLineChart,
    GlAlert,
    ChartSkeletonLoader,
  },
  startDate: START_DATE,
  endDate: TODAY,
  dataKey: 'nodes',
  pageInfoKey: 'pageInfo',
  firstKey: 'first',
  props: {
    prefix: {
      type: String,
      required: false,
      default: '',
    },
    keyToNameMap: {
      type: Object,
      required: true,
    },
    chartTitle: {
      type: String,
      required: true,
    },
    loadChartErrorMessage: {
      type: String,
      required: true,
    },
    noDataMessage: {
      type: String,
      required: true,
    },
    xAxisTitle: {
      type: String,
      required: true,
    },
    yAxisTitle: {
      type: String,
      required: true,
    },
    queries: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      loading: true,
      loadingError: null,
      queryPageInfo: {},
      ...this.queries.reduce(
        (acc, { name }) => ({
          ...acc,
          [name]: [],
        }),
        {},
      ),
    };
  },
  computed: {
    nameKeys() {
      return Object.keys(this.keyToNameMap);
    },
    isLoading() {
      return some(this.$apollo.queries, query => query.loading);
    },
    hasEmptyDataSet() {
      return this.chartData.every(({ data }) => data.length === 0);
    },
    chartData() {
      const options = { shouldRound: true };
      return this.queries.map(({ name, title }) => {
        return { name: title, data: getAverageByMonth(this[name], options) };
      });
    },
    range() {
      return {
        min: this.$options.startDate,
        max: this.$options.endDate,
      };
    },
    chartOptions() {
      const { endDate, startDate } = this.$options;
      return {
        xAxis: {
          ...this.range,
          name: this.xAxisTitle,
          type: 'time',
          splitNumber: differenceInMonths(startDate, endDate) + 1,
          axisLabel: {
            interval: 0,
            showMinLabel: false,
            showMaxLabel: false,
            align: 'right',
            formatter: formatDateAsMonth,
          },
        },
        yAxis: {
          name: this.yAxisTitle,
        },
      };
    },
  },
  created() {
    this.queries.forEach(({ query, name, identifier }) => {
      this.queryPageInfo[name] = {};

      this.$apollo.addSmartQuery(name, {
        query,
        variables() {
          return {
            identifier: identifier.toUpperCase(),
            first: this.totalDataPoints,
            after: null,
          };
        },
        update(data) {
          return data.instanceStatisticsMeasurements?.nodes || [];
        },
        result({ data }) {
          const {
            instanceStatisticsMeasurements: { pageInfo },
          } = data;
          this.queryPageInfo[name] = pageInfo;
          this.fetchNextPage({
            query: this.$apollo.queries[name],
            pageInfo: this.queryPageInfo[name],
            name,
            identifier,
            errorMessage: this.loadChartError,
          });
        },
        error(error) {
          this.handleError({
            message: this.loadGroupsDataError,
            error,
            dataKey: name,
          });
        },
      });
    });
  },
  methods: {
    handleError() {
      this.loadingError = true;
    },
    fetchNextPage({ query, pageInfo, identifier, name }) {
      // TODO: properly track how much data we have fetched
      if (pageInfo?.hasNextPage) {
        query
          .fetchMore({
            variables: {
              identifier,
              first: this.totalDataPoints,
              after: pageInfo.endCursor,
            },
            updateQuery: (previousResult, { fetchMoreResult }) => {
              return produce(fetchMoreResult, newData => {
                // eslint-disable-next-line no-param-reassign
                newData.instanceStatisticsMeasurements.nodes = [
                  ...previousResult.instanceStatisticsMeasurements.nodes,
                  ...newData.instanceStatisticsMeasurements.nodes,
                ];
              });
            },
          })
          .catch(this.handleError);
      }
    },
  },
};
</script>
<template>
  <div>
    <h3>{{ chartTitle }}</h3>
    <gl-alert v-if="loadingError" variant="danger" :dismissible="false" class="gl-mt-3">
      {{ loadChartErrorMessage }}
    </gl-alert>
    <chart-skeleton-loader v-else-if="isLoading" />
    <gl-alert v-else-if="hasEmptyDataSet" variant="info" :dismissible="false" class="gl-mt-3">
      {{ noDataMessage }}
    </gl-alert>
    <gl-line-chart v-else :option="chartOptions" :include-legend-avg-max="true" :data="chartData" />
  </div>
</template>
