<script>
import { GlLineChart } from '@gitlab/ui/dist/charts';
import { reverse } from 'lodash';
import produce from 'immer';
import createFlash from '~/flash';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import { __ } from '~/locale';
import { formatDate, getDateInPast, getMonthNames } from '~/lib/utils/datetime_utility';
import latestUsersQuery from '../graphql/queries/latest_users_count.query.graphql';

// TODO: we want to fetch 1 year's worth
// TODO: if there is no count for a day, do we get 0?
// TODO: group chart data by month

export const formatTickAsMonth = val => {
  const date = new Date(val);
  const month = date.getUTCMonth();
  const year = date.getUTCFullYear();
  return month === 0 ? `${year}` : `${getMonthNames(true)[month]} ${year}`;
};

const TOTAL_DATAPOINTS_TO_FETCH = 365;
const ymd = d => formatDate(d, 'yyyy-mm-dd');
const TODAY = new Date();
const START_DATE = getDateInPast(TODAY, TOTAL_DATAPOINTS_TO_FETCH);

export default {
  name: 'UsersChart',
  components: { GlLineChart, ChartSkeletonLoader },
  data() {
    return {
      usersDailyCount: [],
      pageInfo: null,
    };
  },
  apollo: {
    usersDailyCount: {
      query: latestUsersQuery,
      variables: {
        first: TOTAL_DATAPOINTS_TO_FETCH,
        after: null,
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
        this.$apollo.queries.usersDailyCount.loading ||
        this.usersDailyCount.length < TOTAL_DATAPOINTS_TO_FETCH
      );
    },
    range() {
      return {
        max: TODAY,
        min: START_DATE,
      };
    },
    options() {
      return {
        xAxis: {
          ...this.range,
          name: __('Date'),
          type: 'time',
          // 28 days
          minInterval: 28 * 86400 * 1000,
          axisLabel: {
            formatter: formatTickAsMonth,
          },
        },
        yAxis: {
          name: __('Users'),
        },
      };
    },
    chartUserData() {
      // TODO: this is temporary until we can sort via the query
      const d = reverse(this.usersDailyCount, 'recordedAt');
      // NOTE: for testing, to ensure the chart renders correctly with sparse data
      return [...d.slice(0, 10), ...d.slice(50, 100), ...d.slice(180, 220), ...d.slice(290, 350)];
    },
  },
  methods: {
    fetchNextPage() {
      if (this.pageInfo.hasNextPage) {
        this.$apollo.queries.usersDailyCount.fetchMore({
          variables: { first: TOTAL_DATAPOINTS_TO_FETCH, after: this.pageInfo.endCursor },
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
  <chart-skeleton-loader v-if="isLoading" />
  <gl-line-chart
    v-else
    :option="options"
    :include-legend-avg-max="false"
    :data="[
      {
        name: 'Users',
        data: chartUserData,
      },
    ]"
  />
</template>
