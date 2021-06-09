<script>
import * as DoraApi from 'ee/api/dora_api';
import createFlash from '~/flash';
import { humanizeTimeInterval } from '~/lib/utils/datetime_utility';
import { s__ } from '~/locale';
import CiCdAnalyticsCharts from '~/vue_shared/components/ci_cd_analytics/ci_cd_analytics_charts.vue';
import DoraChartHeader from './dora_chart_header.vue';
import {
  allChartDefinitions,
  areaChartOptions,
  chartDescriptionText,
  chartDocumentationHref,
  LAST_WEEK,
  LAST_MONTH,
  LAST_90_DAYS,
  CHART_TITLE,
} from './static_data/lead_time';
import { buildNullSeriesForLeadTimeChart, apiDataToChartSeries } from './util';

export default {
  name: 'LeadTimeCharts',
  components: {
    CiCdAnalyticsCharts,
    DoraChartHeader,
  },
  inject: {
    projectPath: {
      type: String,
      default: '',
    },
    groupPath: {
      type: String,
      default: '',
    },
  },
  data() {
    return {
      chartData: {
        [LAST_WEEK]: [],
        [LAST_MONTH]: [],
        [LAST_90_DAYS]: [],
      },
      tooltipTitle: null,
      tooltipValue: null,
    };
  },
  computed: {
    charts() {
      return allChartDefinitions.map((chart) => ({
        ...chart,
        data: this.chartData[chart.id],
      }));
    },
  },
  async mounted() {
    if (!this.checkProvidedPaths()) {
      return;
    }

    const results = await Promise.allSettled(
      allChartDefinitions.map(async ({ id, requestParams, startDate, endDate }) => {
        const { data: apiData } = this.projectPath
          ? await DoraApi.getProjectDoraMetrics(
              this.projectPath,
              DoraApi.LEAD_TIME_FOR_CHANGES,
              requestParams,
            )
          : await DoraApi.getGroupDoraMetrics(
              this.groupPath,
              DoraApi.LEAD_TIME_FOR_CHANGES,
              requestParams,
            );

        this.chartData[id] = buildNullSeriesForLeadTimeChart(
          apiDataToChartSeries(apiData, startDate, endDate, CHART_TITLE, null),
        );
      }),
    );

    const requestErrors = results.filter((r) => r.status === 'rejected').map((r) => r.reason);

    if (requestErrors.length) {
      const allErrorMessages = requestErrors.join('\n');

      createFlash({
        message: this.$options.i18n.flashMessage,
        error: new Error(`Something went wrong while getting lead time data:\n${allErrorMessages}`),
        captureError: true,
      });
    }
  },
  methods: {
    formatTooltipText(params) {
      this.tooltipTitle = params.value;
      const seconds = params.seriesData[1].data[1];

      this.tooltipValue = seconds != null ? humanizeTimeInterval(seconds) : null;
    },
    /**
     * Validates that exactly one of [this.projectPath, this.groupPath] has been
     * provided to this component. If not, a flash message is shown and an error
     * is logged with Sentry. This is mainly intended to be a development aid.

     * @returns {Boolean} Whether or not the paths are valid
     */
    checkProvidedPaths() {
      let errorMessage = '';

      if (this.projectPath && this.groupPath) {
        errorMessage = 'Both projectPath and groupPath were provided';
      }

      if (!this.projectPath && !this.groupPath) {
        errorMessage = 'Either projectPath or groupPath must be provided';
      }

      if (errorMessage) {
        createFlash({
          message: this.$options.i18n.flashMessage,
          error: new Error(`Error while rendering lead time charts: ${errorMessage}`),
          captureError: true,
        });

        return false;
      }

      return true;
    },
  },
  areaChartOptions,
  chartDescriptionText,
  chartDocumentationHref,
  i18n: {
    flashMessage: s__('DORA4Metrics|Something went wrong while getting lead time data.'),
    chartHeaderText: s__('DORA4Metrics|Lead time'),
    medianLeadTime: s__('DORA4Metrics|Median lead time'),
    noMergeRequestsDeployed: s__('DORA4Metrics|No merge requests were deployed during this period'),
  },
};
</script>
<template>
  <div data-testid="lead-time-charts">
    <dora-chart-header
      :header-text="$options.i18n.chartHeaderText"
      :chart-description-text="$options.chartDescriptionText"
      :chart-documentation-href="$options.chartDocumentationHref"
    />

    <!-- Using renderer="canvas" here, otherwise the area chart coloring doesn't work if the
         first value in the series is `null`. This appears to have been fixed in ECharts v5,
         so once we upgrade, we can go back to using the default renderer (SVG). -->
    <ci-cd-analytics-charts
      :charts="charts"
      :chart-options="$options.areaChartOptions"
      :format-tooltip-text="formatTooltipText"
      renderer="canvas"
    >
      <template #tooltip-title> {{ tooltipTitle }} </template>
      <template #tooltip-content>
        <template v-if="tooltipValue === null">
          {{ $options.i18n.noMergeRequestsDeployed }}
        </template>
        <div v-else class="gl-display-flex gl-align-items-flex-end">
          <div class="gl-mr-5">{{ $options.i18n.medianLeadTime }}</div>
          <div class="gl-font-weight-bold" data-testid="tooltip-value">{{ tooltipValue }}</div>
        </div>
      </template>
    </ci-cd-analytics-charts>
  </div>
</template>
