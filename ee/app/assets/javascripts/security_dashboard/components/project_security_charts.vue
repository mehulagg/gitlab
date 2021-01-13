<script>
import { GlLoadingIcon } from '@gitlab/ui';
import { GlLineChart } from '@gitlab/ui/dist/charts';
import { s__, __ } from '~/locale';
import createFlash from '~/flash';
import { formatDate, getDateInPast } from '~/lib/utils/datetime_utility';
import { createProjectLoadingError } from '../helpers';
import DashboardNotConfigured from './empty_states/reports_not_configured.vue';
import SecurityChartsLayout from './security_charts_layout.vue';
import projectsHistoryQuery from '../graphql/project_vulnerabilities_by_day_and_count.graphql';

const MAX_DAYS = 100;
const ISO_DATE = 'isoDate';
const SEVERITIES = [
  { key: 'critical', name: s__('severity|Critical'), color: '#660e00' },
  { key: 'high', name: s__('severity|High'), color: '#ae1800' },
  { key: 'medium', name: s__('severity|Medium'), color: '#9e5400' },
  { key: 'low', name: s__('severity|Low'), color: '#c17d10' },
  { key: 'unknown', name: s__('severity|Unknown'), color: '#868686' },
  { key: 'info', name: s__('severity|Info'), color: '#428fdc' },
];

export default {
  components: {
    DashboardNotConfigured,
    SecurityChartsLayout,
    GlLoadingIcon,
    GlLineChart,
  },
  props: {
    projectFullPath: {
      type: String,
      required: false,
      default: '',
    },
    hasVulnerabilities: {
      type: Boolean,
      required: false,
      default: false,
    },
    helpPath: {
      type: String,
      required: true,
    },
  },
  apollo: {
    trendsByDay: {
      query: projectsHistoryQuery,
      variables() {
        return {
          fullPath: this.projectFullPath,
          endDate: this.endDate,
          startDate: this.startDate,
        };
      },
      update(data) {
        return data?.project?.vulnerabilitiesCountByDay?.nodes ?? [];
      },
      error() {
        createFlash({ message: createProjectLoadingError() });
      },
      skip() {
        return !this.hasVulnerabilities;
      },
    },
  },
  data() {
    return {
      chartWidth: 0,
      trendsByDay: [],
    };
  },
  computed: {
    startDate() {
      return formatDate(getDateInPast(new Date(), MAX_DAYS), ISO_DATE);
    },
    endDate() {
      return formatDate(new Date(), ISO_DATE);
    },
    dataSeries() {
      const series = SEVERITIES.map(({ key, name, color }) => ({
        key,
        name,
        data: [],
        itemStyle: {
          color,
        },
        lineStyle: {
          color,
        },
      }));

      this.trendsByDay.forEach((trend) => {
        const { date, ...severities } = trend;

        SEVERITIES.forEach(({ key }) => {
          series.find((s) => s.key === key).data.push([date, severities[key]]);
        });
      });

      return series;
    },
    isLoadingTrends() {
      return this.$apollo.queries.trendsByDay.loading;
    },
    shouldShowCharts() {
      return Boolean(!this.isLoadingTrends && this.trendsByDay.length) && this.chartWidth > 0;
    },
    shouldShowEmptyState() {
      return !this.hasVulnerabilities;
    },
  },
  mounted() {
    this.chartWidth = this.$refs.layout.$el.clientWidth;
  },
  chartOptions: {
    xAxis: {
      name: __('Time'),
      key: 'time',
      type: 'category',
    },
    yAxis: {
      name: __('Vulnerabilities'),
      key: 'vulnerabilities',
      type: 'value',
      minInterval: 1,
    },
  },
};
</script>

<template>
  <security-charts-layout ref="layout">
    <template v-if="shouldShowEmptyState" #empty-state>
      <dashboard-not-configured :help-path="helpPath" />
    </template>
    <template v-else-if="shouldShowCharts">
      <gl-line-chart
        class="gl-mt-6"
        :width="chartWidth"
        :data="dataSeries"
        :option="$options.chartOptions"
        :include-legend-avg-max="false"
      />
    </template>
    <template v-else #loading>
      <gl-loading-icon size="lg" class="gl-mt-6" />
    </template>
  </security-charts-layout>
</template>
