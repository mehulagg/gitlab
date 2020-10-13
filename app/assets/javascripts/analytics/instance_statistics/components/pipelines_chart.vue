<script>
import { GlLineChart } from '@gitlab/ui/dist/charts';
import produce from 'immer';
import createFlash from '~/flash';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import { __ } from '~/locale';
import { formatDateAsMonth } from '~/lib/utils/datetime_utility';
import { getAverageByMonth, sortByDate } from '../utils';
import pipelineStatsQuery from '../graphql/queries/pipeline_stats.query.graphql';

export default {
  name: 'PipelinesChart',
  components: {
    GlLineChart,
    ChartSkeletonLoader,
  },
  props: {
    startDate: {
      type: Date,
      required: true,
    },
    endDate: {
      type: Date,
      required: true,
    },
    totalDataPoints: {
      type: Number,
      required: true,
    },
  },
  data() {
    return {
      loading: true,
    };
  },
  apollo: {
    pipelineStats: {
      query: pipelineStatsQuery,
      variables() {
        return {
          first: this.totalDataPoints,
        };
      },
      update(data) {
        const {
          pipelinesTotal: { pageInfo: pageInfoTotal = {}, nodes: dataTotal = [] } = {},
          pipelinesSucceeded: { pageInfo: pageInfoSucceeded = {}, nodes: dataSucceeded = [] } = {},
          pipelinesFailed: { pageInfo: pageInfoFailed = {}, nodes: dataFailed = [] } = {},
          pipelinesCanceled: { pageInfo: pageInfoCanceled = {}, nodes: dataCanceled = [] } = {},
          pipelinesSkipped: { pageInfo: pageInfoSkipped = {}, nodes: dataSkipped = [] } = {},
        } = data;

        return {
          dataTotal,
          dataSucceeded,
          dataFailed,
          dataCanceled,
          dataSkipped,
          pageInfoTotal,
          pageInfoSucceeded,
          pageInfoFailed,
          pageInfoCanceled,
          pageInfoSkipped,
        };
      },
      result() {
        if (this.hasNextPage) {
          this.fetchNextPage();
        } else {
          this.loading = false;
        }
      },
      error(error) {
        this.handleError(error);
      },
    },
  },
  i18n: {
    loadPipelineChartError: __(
      'Could not load the pipelines chart. Please refresh the page to try again.',
    ),
    total: __('Total'),
    succeeded: __('Succeeded'),
    failed: __('Failed'),
    canceled: __('Canceled'),
    skipped: __('Skipped'),
    yAxisTitle: __('Items'),
    xAxisTitle: __('Month'),
  },
  computed: {
    isLoading() {
      // Don't show the chart until all data is fetched
      return this.loading || this.$apollo.queries.pipelineStats.loading;
    },
    cursorVariables() {
      const {
        pageInfoTotal,
        pageInfoSucceeded,
        pageInfoFailed,
        pageInfoCanceled,
        pageInfoSkipped,
      } = this.pipelineStats;
      return {
        afterTotal: pageInfoTotal.endCursor,
        afterSucceeded: pageInfoSucceeded.endCursor,
        afterFailed: pageInfoFailed.endCursor,
        afterCanceled: pageInfoCanceled.endCursor,
        afterSkipped: pageInfoSkipped.endCursor,
      };
    },
    hasNextPage() {
      const {
        pageInfoTotal,
        pageInfoSucceeded,
        pageInfoFailed,
        pageInfoCanceled,
        pageInfoSkipped,
      } = this.pipelineStats;
      return (
        pageInfoTotal.hasNextPage ||
        pageInfoSucceeded.hasNextPage ||
        pageInfoFailed.hasNextPage ||
        pageInfoCanceled.hasNextPage ||
        pageInfoSkipped.hasNextPage
      );
    },
    chartData() {
      const {
        dataTotal,
        dataSucceeded,
        dataFailed,
        dataCanceled,
        dataSkipped,
      } = this.pipelineStats;
      return [
        {
          name: this.$options.i18n.total,
          data: sortByDate(getAverageByMonth(dataTotal)),
        },
        {
          name: this.$options.i18n.succeeded,
          data: sortByDate(getAverageByMonth(dataSucceeded)),
        },
        {
          name: this.$options.i18n.failed,
          data: sortByDate(getAverageByMonth(dataFailed)),
        },
        {
          name: this.$options.i18n.canceled,
          data: sortByDate(getAverageByMonth(dataCanceled)),
        },
        {
          name: this.$options.i18n.skipped,
          data: sortByDate(getAverageByMonth(dataSkipped)),
        },
      ];
    },
    range() {
      return {
        min: this.startDate,
        max: this.endDate,
      };
    },
    chartOptions() {
      return {
        xAxis: {
          ...this.range,
          name: this.$options.i18n.xAxisTitle,
          type: 'time',
          splitNumber: 12,
          axisLabel: {
            interval: 0,
            showMinLabel: false,
            showMaxLabel: false,
            align: 'right',
            formatter: formatDateAsMonth,
          },
        },
        yAxis: {
          name: this.$options.i18n.yAxisTitle,
        },
      };
    },
  },
  methods: {
    handleError(error) {
      createFlash({
        message: this.$options.i18n.loadPipelineChartError,
        captureError: true,
        error,
      });
      this.loading = false;
    },
    fetchNextPage() {
      this.$apollo.queries.pipelineStats
        .fetchMore({
          variables: {
            first: this.totalDataPoints,
            ...this.cursorVariables,
          },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            const {
              pipelinesTotal: { nodes: pipelinesTotal },
              pipelinesSucceeded: { nodes: pipelinesSucceeded },
              pipelinesFailed: { nodes: pipelinesFailed },
              pipelinesCanceled: { nodes: pipelinesCanceled },
              pipelinesSkipped: { nodes: pipelinesSkipped },
            } = previousResult;
            return produce(fetchMoreResult, newResponse => {
              // eslint-disable-next-line no-param-reassign
              newResponse.pipelinesTotal.nodes = [
                ...pipelinesTotal,
                ...newResponse.pipelinesTotal.nodes,
              ];
              // eslint-disable-next-line no-param-reassign
              newResponse.pipelinesSucceeded.nodes = [
                ...pipelinesSucceeded,
                ...newResponse.pipelinesSucceeded.nodes,
              ];
              // eslint-disable-next-line no-param-reassign
              newResponse.pipelinesFailed.nodes = [
                ...pipelinesFailed,
                ...newResponse.pipelinesFailed.nodes,
              ];
              // eslint-disable-next-line no-param-reassign
              newResponse.pipelinesCanceled.nodes = [
                ...pipelinesCanceled,
                ...newResponse.pipelinesCanceled.nodes,
              ];
              // eslint-disable-next-line no-param-reassign
              newResponse.pipelinesSkipped.nodes = [
                ...pipelinesSkipped,
                ...newResponse.pipelinesSkipped.nodes,
              ];
            });
          },
        })
        .catch(error => {
          this.handleError(error);
        });
    },
  },
};
</script>
<template>
  <div>
    <h3>{{ __('Pipelines') }}</h3>
    <chart-skeleton-loader v-if="isLoading" />
    <gl-line-chart v-else :option="chartOptions" :include-legend-avg-max="true" :data="chartData" />
  </div>
</template>
