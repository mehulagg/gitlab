<script>
import { GlLineChart } from '@gitlab/ui/dist/charts';
import { reverse } from 'lodash';
import produce from 'immer';
import createFlash from '~/flash';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import { __ } from '~/locale';
// Interesting
import ResizableChartContainer from '~/vue_shared/components/resizable_chart/resizable_chart_container.vue';
// Interesting
import { formatDate, getDatesInRange, getDateInPast } from '~/lib/utils/datetime_utility';
import latestUsersQuery from '../graphql/queries/latest_users_count.query.graphql';

// TODO: we want to fetch 1 year's worth
// TODO: if there is no count for a day, do we get 0?
// TODO: group chart data by month

const TIME_PERIOD_IN_DAYS = 365;
const ymd = d => formatDate(d, 'yyyy-mm-dd');
const FETCH_LIMIT = TIME_PERIOD_IN_DAYS;
// TODO: check if empty days are returned
// Maybe we use a Map() to store the entries by their date
// const TODAY = new Date();
// const START_DATE = getDateInPast(TODAY, TIME_PERIOD_IN_DAYS);
// const DATE_RANGE = getDatesInRange(START_DATE, TODAY).map(ymd);

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
        first: FETCH_LIMIT,
        after: null,
      },
      update(data) {
        // TODO: might need to cache data, so that we can add 0 values
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
        this.$apollo.queries.usersDailyCount.loading || this.usersDailyCount.length < FETCH_LIMIT
      );
    },
    range() {
      return {
        min: this.usersDailyCount[0][0],
        max: this.usersDailyCount[this.usersDailyCount.length - 1][0],
      };
    },
    options() {
      return {
        xAxis: {
          // ...this.range,
          name: __('Date'),
          type: 'category',
        },
        yAxis: {
          name: __('Users'),
        },
      };
    },
    chartUserData() {
      // TODO: this is temporary until we can sort via the query
      return reverse(this.usersDailyCount, 'recordedAt');
    },
  },
  methods: {
    fetchNextPage() {
      if (this.pageInfo.hasNextPage) {
        this.$apollo.queries.usersDailyCount.fetchMore({
          variables: { first: FETCH_LIMIT, after: this.pageInfo.endCursor },
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
