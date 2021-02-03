<script>
import { GlAreaChart } from '@gitlab/ui/dist/charts';
import { GlCard, GlSprintf } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import MetricCard from '~/analytics/shared/components/metric_card.vue';
import { formatDate } from '~/lib/utils/datetime_utility';
import ChartSkeletonLoader from '~/vue_shared/components/resizable_chart/skeleton_loader.vue';
import getGroupTestCoverage from '../graphql/queries/get_group_test_coverage.query.graphql';

export default {
  name: 'TestCoverageSummary',
  components: {
    ChartSkeletonLoader,
    GlAreaChart,
    GlCard,
    GlSprintf,
    MetricCard,
  },
  inject: {
    groupFullPath: {
      default: '',
    },
  },
  apollo: {
    group: {
      query: getGroupTestCoverage,
      variables() {
        const THIRTY_DAYS = 30 * 24 * 60 * 60 * 1000; // milliseconds

        return {
          groupFullPath: this.groupFullPath,
          startDate: new Date(Date.now() - THIRTY_DAYS),
        };
      },
      result(res) {
        const groupCoverage = res.data?.group?.codeCoverageActivities?.nodes;
        const { projectCount, averageCoverage, coverageCount } =
          groupCoverage?.[groupCoverage.length - 1] || {};

        this.projectCount = projectCount;
        this.averageCoverage = averageCoverage;
        this.coverageCount = coverageCount;
        this.groupCoverageChartData = [
          {
            name: this.$options.text.graphName,
            data: groupCoverage.map((coverage) => [
              formatDate(coverage.date, 'mmm dd'),
              coverage.averageCoverage,
            ]),
          },
        ];
      },
      error() {
        this.hasError = true;
        this.projectCount = null;
        this.averageCoverage = null;
        this.coverageCount = null;
        this.groupCoverageChartData = [];
      },
      watchLoading(isLoading) {
        this.isLoading = isLoading;
      },
    },
  },
  data() {
    return {
      projectCount: null,
      averageCoverage: null,
      coverageCount: null,
      groupCoverageChartData: [],
      coveragePercentage: null,
      tooltipTitle: null,
      hasError: false,
      isLoading: false,
    };
  },
  i18n: {
    cardTitle: __('Overall Activity'),
  },
  computed: {
    metrics() {
      return [
        {
          key: 'projectCount',
          value: this.projectCount,
          label: s__('RepositoriesAnalytics|Projects with Coverage'),
        },
        {
          key: 'averageCoverage',
          value: this.averageCoverage,
          unit: '%',
          label: s__('RepositoriesAnalytics|Average Coverage by Job'),
        },
        {
          key: 'coverageCount',
          value: this.coverageCount,
          label: s__('RepositoriesAnalytics|Jobs with Coverage'),
        },
      ];
    },
    chartOptions() {
      return {
        xAxis: {
          name: this.$options.text.xAxisName,
          type: 'category',
        },
        yAxis: {
          name: this.$options.text.yAxisName,
          type: 'value',
          min: 0,
          max: 100,
          axisLabel: {
            formatter: (value) => `${value}%`,
          },
        },
      };
    },
  },
  methods: {
    formatTooltipText(params) {
      this.tooltipTitle = params.value;
      this.coveragePercentage = params.seriesData?.[0]?.data?.[1];
    },
  },
  text: {
    graphCardHeader: s__('RepositoriesAnalytics|Average test coverage last 30 days'),
    yAxisName: __('Coverage'),
    xAxisName: __('Date'),
    graphName: s__('RepositoriesAnalytics|Average coverage'),
  },
};
</script>
<template>
  <div>
    <metric-card :title="$options.i18n.cardTitle" :metrics="metrics" :is-loading="isLoading" />

    <gl-card>
      <template #header>
        <h5>{{ $options.text.graphCardHeader }}</h5>
      </template>

      <chart-skeleton-loader v-if="isLoading" />

      <gl-area-chart
        v-else
        :data="groupCoverageChartData"
        :option="chartOptions"
        :include-legend-avg-max="false"
        :format-tooltip-text="formatTooltipText"
      >
        <template #tooltip-title>
          {{ tooltipTitle }}
        </template>
        <template #tooltip-content>
          <gl-sprintf :message="__('Code Coverage: %{coveragePercentage}%{percentSymbol}')">
            <template #coveragePercentage>
              {{ coveragePercentage }}
            </template>
            <template #percentSymbol>%</template>
          </gl-sprintf>
        </template>
      </gl-area-chart>
    </gl-card>
  </div>
</template>
