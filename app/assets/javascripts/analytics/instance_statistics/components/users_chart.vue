<script>
import { GlLineChart } from '@gitlab/ui/dist/charts';
import produce from 'immer';
import createFlash from '~/flash';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import { __ } from '~/locale';
import { formatDate, getMonthNames } from '~/lib/utils/datetime_utility';
import latestUsersQuery from '../graphql/queries/latest_users_count.query.graphql';

// TODO: we want to fetch 1 year's worth
// TODO: if there is no count for a day, do we get 0?
// TODO: group chart data by month
// TODO: include total but not average

export const formatTickAsMonth = val => {
  const month = new Date(val).getUTCMonth();
  return getMonthNames(true)[month];
};

const ymd = d => formatDate(d, 'yyyy-mm-dd');

export default {
  name: 'UsersChart',
  components: { GlLineChart, ChartSkeletonLoader },
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
      usersTotal: [],
      pageInfo: null,
    };
  },
  apollo: {
    usersTotal: {
      query: latestUsersQuery,
      variables() {
        return {
          first: this.totalDataPoints,
          after: null,
        };
      },
      update(data) {
        return data.users.nodes.map(({ count, recordedAt }) => [ymd(recordedAt), count]);
      },
      result({ data }) {
        const {
          users: { pageInfo },
        } = data;
        this.pageInfo = pageInfo;
        this.fetchNextPage();
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
      return (
        this.$apollo.queries.usersTotal.loading || this.usersTotal.length < this.totalDataPoints
      );
    },
    range() {
      return {
        min: this.startDate,
        max: this.endDate,
      };
    },
    options() {
      return {
        xAxis: {
          ...this.range,
          type: 'time',
          name: __('Date'),
          splitNumber: 12,
          axisLabel: {
            interval: 0,
            showMinLabel: false,
            showMaxLabel: false,
            formatter: formatTickAsMonth,
            align: 'right',
          },
          axisTick: {
            alignWithLabel: false,
          },
        },
        yAxis: {
          name: __('Users'),
        },
      };
    },
    chartUserData() {
      return this.usersTotal;
    },
  },
  methods: {
    fetchNextPage() {
      if (this.pageInfo.hasNextPage) {
        this.$apollo.queries.usersTotal.fetchMore({
          variables: { first: this.totalDataPoints, after: this.pageInfo.endCursor },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            const results = produce(fetchMoreResult, newUsers => {
              // eslint-disable-next-line no-param-reassign
              newUsers.users.nodes = [...previousResult.users.nodes, ...newUsers.users.nodes];
            });
            return results;
          },
        });
      }
    },
  },
};
</script>
<template>
  <div>
    <h3>{{ __('Users') }}</h3>
    <chart-skeleton-loader v-if="isLoading" />
    <gl-line-chart
      v-else
      :option="options"
      :include-legend-avg-max="true"
      :data="[
        {
          name: 'Users',
          data: chartUserData,
        },
      ]"
    />
  </div>
</template>
