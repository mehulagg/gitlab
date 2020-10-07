<script>
import { GlLineChart } from '@gitlab/ui/dist/charts';
import produce from 'immer';
import createFlash from '~/flash';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import { __ } from '~/locale';
import { formatDateAsMonth } from '~/lib/utils/datetime_utility';
import { getAverageByMonth } from '../utils';
import issuesAndMergeRequestsQuery from '../graphql/queries/issues_and_merge_requests.query.graphql';

// TODO: Handle loading when data points are still loading!
// this.issues.length < 12 || this.mergeRequests.length < 12

export default {
  name: 'IssuesAndMergeRequestsChart',
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
      issues: [],
      mergeRequests: [],
      issuesPageInfo: null,
      mergeRequestsPageInfo: null,
    };
  },
  apollo: {
    issuesAndMergeRequests: {
      query: issuesAndMergeRequestsQuery,
      variables() {
        return {
          first: this.totalDataPoints,
          after: null,
        };
      },
      update: data => data,
      result({ data }) {
        const {
          issues: { pageInfo: issuesPageInfo, nodes: issues },
          mergeRequests: { pageInfo: mergeRequestsPageInfo, nodes: mergeRequests },
        } = data;
        this.issues = getAverageByMonth(issues);
        this.mergeRequests = getAverageByMonth(mergeRequests);
        this.issuesPageInfo = issuesPageInfo;
        this.mergeRequestsPageInfo = mergeRequestsPageInfo;
        if (issuesPageInfo.hasNextPage || mergeRequestsPageInfo.hasNextPage) {
          this.fetchNextPage();
        }
      },
      error(error) {
        createFlash({ message: this.$options.i18n.loadUserChartError, captureError: true, error });
      },
    },
  },
  i18n: {
    loadUserChartError: __('Could not load the user chart. Please refresh the page to try again.'),
  },
  computed: {
    isLoading() {
      // Dont show the chart until all data is fetched
      return this.$apollo.queries.issuesAndMergeRequests.loading;
    },
    chartData() {
      return [
        {
          name: __('Issues'),
          data: this.issues,
        },
        {
          name: __('Merge Requests'),
          data: this.mergeRequests,
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
    fetchNextPage() {
      this.$apollo.queries.issuesAndMergeRequests.fetchMore({
        variables: {
          first: this.totalDataPoints,
          afterIssue: this.issuesPageInfo.endCursor,
          afterMergeRequest: this.mergeRequestsPageInfo.endCursor,
        },
        updateQuery: (previousResult, { fetchMoreResult }) => {
          const {
            issues: { nodes: previousIssues },
            mergeRequests: { nodes: previousMergeRequests },
          } = previousResult;
          return produce(fetchMoreResult, newIssues => {
            // eslint-disable-next-line no-param-reassign
            newIssues.issues.nodes = [...previousIssues, ...newIssues.issues.nodes];
            // eslint-disable-next-line no-param-reassign
            newIssues.mergeRequests.nodes = [
              ...previousMergeRequests,
              ...newIssues.mergeRequests.nodes,
            ];
          });
        },
      });
    },
  },
};
</script>
<template>
  <div>
    <h3>{{ __('Issues & Merge Requests') }}</h3>
    <chart-skeleton-loader v-if="isLoading" />
    <gl-line-chart v-else :option="chartOptions" :include-legend-avg-max="true" :data="chartData" />
  </div>
</template>
