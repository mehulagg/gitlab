<script>
import { GlAlert } from '@gitlab/ui';
import { GlAreaChart } from '@gitlab/ui/dist/charts';
import produce from 'immer';
import createFlash from '~/flash';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import { __ } from '~/locale';
import { formatDateAsMonth } from '~/lib/utils/datetime_utility';
import latestUsersQuery from '../graphql/queries/latest_users_count.query.graphql';
import { getAverageByMonth } from '../utils';

const unix = d => new Date(d).getTime();
const sortByDate = data => [...data].sort((a, b) => unix(a[0]) > unix(b[0]));

export default {
  name: 'UsersChart',
  components: { GlAlert, GlAreaChart, ChartSkeletonLoader },
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
        return data.users?.nodes || [];
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
    yAxisTitle: __('Users'),
    xAxisTitle: __('Month'),
    loadUserChartError: __('Could not load the user chart. Please refresh the page to try again.'),
    noDataMessage: __('There is no data available.'),
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.usersTotal.loading || this.pageInfo?.hasNextPage;
    },
    chartUserData() {
      const averaged = getAverageByMonth(
        this.usersTotal.length > this.totalDataPoints
          ? this.usersTotal.slice(0, this.totalDataPoints)
          : this.usersTotal,
        true,
      );
      return sortByDate(averaged);
    },
    options() {
      return {
        xAxis: {
          name: this.$options.i18n.xAxisTitle,
          type: 'category',
          axisLabel: {
            formatter: value => {
              return formatDateAsMonth(value);
            },
          },
        },
        yAxis: {
          name: this.$options.i18n.yAxisTitle,
        },
      };
    },
  },
  methods: {
    fetchNextPage() {
      if (this.pageInfo?.hasNextPage) {
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
    <h3>{{ $options.i18n.yAxisTitle }}</h3>
    <chart-skeleton-loader v-if="isLoading" />
    <gl-alert v-else-if="!chartUserData.length" variant="info" :dismissible="false" class="gl-mt-3">
      {{ $options.i18n.noDataMessage }}
    </gl-alert>
    <gl-area-chart
      v-else
      :option="options"
      :include-legend-avg-max="true"
      :data="[
        {
          name: $options.i18n.yAxisTitle,
          data: chartUserData,
        },
      ]"
    />
  </div>
</template>
