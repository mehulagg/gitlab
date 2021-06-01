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
    const results = await Promise.allSettled(
      allChartDefinitions.map(async ({ id, requestParams, startDate, endDate }) => {
        let apiData;
        if (this.projectPath && this.groupPath) {
          throw new Error('Both projectPath and groupPath were provided');
        } else if (this.projectPath) {
          apiData = (
            await DoraApi.getProjectDoraMetrics(
              this.projectPath,
              DoraApi.LEAD_TIME_FOR_CHANGES,
              requestParams,
            )
          ).data;
        } else if (this.groupPath) {
          apiData = (
            await DoraApi.getGroupDoraMetrics(
              this.groupPath,
              DoraApi.LEAD_TIME_FOR_CHANGES,
              requestParams,
            )
          ).data;
        } else {
          throw new Error('Either projectPath or groupPath must be provided');
        }

        this.chartData[id] = buildNullSeriesForLeadTimeChart(
          apiDataToChartSeries(apiData, startDate, endDate, CHART_TITLE, null),
        );
      }),
    );

    const requestErrors = results.filter((r) => r.status === 'rejected').map((r) => r.reason);

    if (requestErrors.length) {
      const allErrorMessages = requestErrors.join('\n');

      createFlash({
        message: s__('DORA4Metrics|Something went wrong while getting lead time data.'),
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
  },
  areaChartOptions,
  chartDescriptionText,
  chartDocumentationHref,
};
</script>
<template>
  <div>
    <dora-chart-header
      :header-text="s__('DORA4Metrics|Lead time')"
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
          {{ s__('DORA4Metrics|No merge requests were deployed during this period') }}
        </template>
        <div v-else class="gl-display-flex gl-align-items-flex-end">
          <div class="gl-mr-5">{{ s__('DORA4Metrics|Median lead time') }}</div>
          <div class="gl-font-weight-bold" data-testid="tooltip-value">{{ tooltipValue }}</div>
        </div>
      </template>
    </ci-cd-analytics-charts>
  </div>
</template>
