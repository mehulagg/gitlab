<script>
import { GlAlert } from '@gitlab/ui';
import { GlLineChart } from '@gitlab/ui/dist/charts';
import produce from 'immer';
import createFlash from '~/flash';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import { __ } from '~/locale';
import { formatDateAsMonth } from '~/lib/utils/datetime_utility';
import latestGroupsQuery from '../graphql/queries/latest_groups_count.query.graphql';
import latestProjectsQuery from '../graphql/queries/latest_projects_count.query.graphql';
import { getAverageByMonth } from '../utils';

const unix = d => new Date(d).getTime();
const sortByDate = data => [...data].sort((a, b) => unix(a[0]) > unix(b[0]));

export default {
  name: 'ProjectsAndGroupsChart',
  components: { GlAlert, GlLineChart, ChartSkeletonLoader },
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
      groups: [],
      projects: [],
      groupsPageInfo: null,
      projectsPageInfo: null,
    };
  },
  apollo: {
    groups: {
      query: latestGroupsQuery,
      variables() {
        return {
          first: this.totalDataPoints,
          after: null,
        };
      },
      update(data) {
        return data.groups?.nodes || [];
      },
      result({ data }) {
        const {
          groups: { pageInfo },
        } = data;
        this.groupsPageInfo = pageInfo;
        this.fetchNextPage({
          query: this.$apollo.queries.groups,
          pageInfo: this.groupsPageInfo,
          dataKey: 'groups',
        });
      },
      error(error) {
        createFlash({ message: this.$options.i18n.loadUserChartError, captureError: true, error });
      },
    },
    projects: {
      query: latestProjectsQuery,
      variables() {
        return {
          first: this.totalDataPoints,
          after: null,
        };
      },
      update(data) {
        return data.projects?.nodes || [];
      },
      result({ data }) {
        const {
          projects: { pageInfo },
        } = data;
        this.projectsPageInfo = pageInfo;
        this.fetchNextPage({
          query: this.$apollo.queries.projects,
          pageInfo: this.projectsPageInfo,
          dataKey: 'projects',
        });
      },
      error(error) {
        createFlash({ message: this.$options.i18n.loadCharError, captureError: true, error });
      },
    },
  },
  i18n: {
    yAxisTitle: __('Projects & Groups'),
    xAxisTitle: __('Month'),
    loadCharError: __(
      'Could not load the projects and groups chart. Please refresh the page to try again.',
    ),
    noDataMessage: __('There is no data available.'),
  },
  computed: {
    isLoadingGroups() {
      return this.$apollo.queries.groups.loading || this.groupsPageInfo?.hasNextPage;
    },
    isLoadingProjects() {
      return this.$apollo.queries.projects.loading || this.projectsPageInfo?.hasNextPage;
    },
    isLoading() {
      return this.isLoadingProjects || this.isLoadingGroups;
    },
    groupChartData() {
      const averaged = getAverageByMonth(
        this.groups.length > this.totalDataPoints
          ? this.groups.slice(0, this.totalDataPoints)
          : this.groups,
        true,
      );
      return sortByDate(averaged);
    },
    projectChartData() {
      const averaged = getAverageByMonth(
        this.projects.length > this.totalDataPoints
          ? this.projects.slice(0, this.totalDataPoints)
          : this.projects,
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
    fetchNextPage({ pageInfo, query, dataKey }) {
      if (pageInfo?.hasNextPage) {
        query.fetchMore({
          variables: { first: this.totalDataPoints, after: pageInfo.endCursor },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            const results = produce(fetchMoreResult, newData => {
              // eslint-disable-next-line no-param-reassign
              newData[dataKey].nodes = [
                ...previousResult[dataKey].nodes,
                ...newData[dataKey].nodes,
              ];
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
    <gl-alert
      v-else-if="!projectChartData.length || !groupChartData.length"
      variant="info"
      :dismissible="false"
      class="gl-mt-3"
    >
      {{ $options.i18n.noDataMessage }}
    </gl-alert>
    <gl-line-chart
      v-else
      :option="options"
      :include-legend-avg-max="true"
      :data="[
        {
          name: 'Projects',
          data: projectChartData,
        },
        {
          name: 'Groups',
          data: groupChartData,
        },
      ]"
    />
  </div>
</template>
