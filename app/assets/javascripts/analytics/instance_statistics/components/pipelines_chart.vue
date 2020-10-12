<script>
import { GlLineChart } from '@gitlab/ui/dist/charts';
import produce from 'immer';
import createFlash from '~/flash';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import { __ } from '~/locale';
import { formatDateAsMonth } from '~/lib/utils/datetime_utility';
import { getAverageByMonth } from '../utils';
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
      pipelinesTotal: [],
      pipelinesSucceeded: [],
      pipelinesFailed: [],
      pipelinesCanceled: [],
      pipelinesSkipped: [],
      pageInfo: null,
      loading: true,
    };
  },
  apollo: {
    pipelineStats: {
      query: pipelineStatsQuery,
      variables() {
        return {
          first: this.totalDataPoints,
          after: null,
        };
      },
      update: data => data,
      result({ data }) {
        const {
          pipelinesTotal: { pageInfo: pageInfoTotal = {}, nodes: pipelinesTotal } = {},
          pipelinesSucceeded: { pageInfo: pageInfoSucceeded = {}, nodes: pipelinesSucceeded } = {},
          pipelinesFailed: { pageInfo: pageInfoFailed = {}, nodes: pipelinesFailed } = {},
          pipelinesCanceled: { pageInfo: pageInfoCanceled = {}, nodes: pipelinesCanceled } = {},
          pipelinesSkipped: { pageInfo: pageInfoSkipped = {}, nodes: pipelinesSkipped } = {},
        } = data;
        this.pipelinesTotal = getAverageByMonth(pipelinesTotal);
        this.pipelinesSucceeded = getAverageByMonth(pipelinesSucceeded);
        this.pipelinesFailed = getAverageByMonth(pipelinesFailed);
        this.pipelinesCanceled = getAverageByMonth(pipelinesCanceled);
        this.pipelinesSkipped = getAverageByMonth(pipelinesSkipped);
        this.pageInfoTotal = pageInfoTotal;
        this.pageInfoSucceeded = pageInfoSucceeded;
        this.pageInfoFailed = pageInfoFailed;
        this.pageInfoCanceled = pageInfoCanceled;
        this.pageInfoSkipped = pageInfoSkipped;
        if (
          pageInfoTotal.hasNextPage ||
          pageInfoSucceeded.hasNextPage ||
          pageInfoFailed.hasNextPage ||
          pageInfoCanceled.hasNextPage ||
          pageInfoSkipped.hasNextPage
        ) {
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
  },
  computed: {
    isLoading() {
      // Don't show the chart until all data is fetched
      return this.loading || this.$apollo.queries.pipelineStats.loading;
    },
    chartData() {
      return [
        {
          name: __('Total'),
          data: this.pipelinesTotal,
        },
        {
          name: __('Succeeded'),
          data: this.pipelinesSucceeded,
        },
        {
          name: __('Failed'),
          data: this.pipelinesFailed,
        },
        {
          name: __('Canceled'),
          data: this.pipelinesCanceled,
        },
        {
          name: __('Skipped'),
          data: this.pipelinesSkipped,
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
          name: __('Month'),
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
          name: __('Items'),
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
            afterTotal: this.pageInfoTotal.endCursor,
            afterSucceeded: this.pageInfoSucceeded.endCursor,
            afterFailed: this.pageInfoFailed.endCursor,
            afterCanceled: this.pageInfoCanceled.endCursor,
            afterSkipped: this.pageInfoSkipped.endCursor,
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
