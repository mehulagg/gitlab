<script>
import * as Sentry from '@sentry/browser';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import { GlLineChart } from '@gitlab/ui/dist/charts';
// Interesting
import ResizableChartContainer from '~/vue_shared/components/resizable_chart/resizable_chart_container.vue';
// Interesting
import dateFormat from 'dateformat';
import { formatDate, getDatesInRange } from '~/lib/utils/datetime_utility';
import latestUsersQuery from '../graphql/queries/latest_users_count.query.graphql';

export default {
  name: 'UsersChart',
  components: { GlLineChart, ChartSkeletonLoader },
  data() {
    return {
      usersCount: [],
    };
  },
  updated() {
    console.log('data', this.data);
  },
  apollo: {
    usersCount: {
      query: latestUsersQuery,
      update(data) {
        console.log('apollo::update::data', data);
        console.log('apollo::update::data.users.nodes', data.users.nodes);
        // return Object.entries(data).map(([key, obj]) => {
        //   const label = this.$options.i18n.labels[key];
        //   const formatter = getFormatter(SUPPORTED_FORMATS.number);
        //   const value = obj.nodes?.length ? formatter(obj.nodes[0].count, defaultPrecision) : null;

        //   return {
        //     key,
        //     value,
        //     label,
        //   };
        // });
        // TODO: might need to cache data, so that we can add 0 values
        return data.users.nodes.map(({ count, recordedAt }) => [
          formatDate(recordedAt, 'yyyy-mm-dd'),
          count,
        ]);
      },
      error(error) {
        createFlash(this.$options.i18n.loadCountsError);
        Sentry.captureException(error);
      },
    },
  },
  i18n: {
    // labels: {
    //   users: s__('InstanceStatistics|Users'),
    //   projects: s__('InstanceStatistics|Projects'),
    //   groups: s__('InstanceStatistics|Groups'),
    //   issues: s__('InstanceStatistics|Issues'),
    //   mergeRequests: s__('InstanceStatistics|Merge Requests'),
    //   pipelines: s__('InstanceStatistics|Pipelines'),
    // },
    // loadCountsError: s__('Could not load instance counts. Please refresh the page to try again.'),
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.usersCount.loading;
    },
    range() {
      return { min: this.usersCount[0][0], max: this.usersCount[this.usersCount.length - 1][0] };
    },
    options() {
      return {
        xAxis: {
          // ...this.range,
          name: 'Date',
          type: 'category',
        },
        yAxis: {
          name: 'Users',
        },
      };
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
        data: usersCount,
      },
    ]"
  />
</template>
