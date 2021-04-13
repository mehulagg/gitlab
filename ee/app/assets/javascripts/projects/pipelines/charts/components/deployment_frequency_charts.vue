<script>
import { GlLink, GlSprintf } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import * as DoraApi from 'ee/api/dora_api';
import createFlash from '~/flash';
import { s__ } from '~/locale';
import CiCdAnalyticsCharts from '~/projects/pipelines/charts/components/ci_cd_analytics_charts.vue';
import {
  allChartDefinitions,
  areaChartOptions,
  chartDescriptionText,
  chartDocumentationHref,
  environmentTierDocumentationHref,
  LAST_WEEK,
  LAST_MONTH,
  LAST_90_DAYS,
  CHART_TITLE,
} from './static_data/deployment_frequency';
import { apiDataToChartSeries } from './util';

export default {
  name: 'DeploymentFrequencyCharts',
  components: {
    GlLink,
    GlSprintf,
    CiCdAnalyticsCharts,
  },
  inject: {
    projectPath: {
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
        const { data: apiData } = await DoraApi.getProjectDoraMetrics(
          this.projectPath,
          DoraApi.DEPLOYMENT_FREQUENCY_METRIC_TYPE,
          requestParams,
        );

        this.chartData[id] = apiDataToChartSeries(apiData, startDate, endDate, CHART_TITLE);
      }),
    );

    const requestErrors = results.filter((r) => r.status === 'rejected').map((r) => r.reason);

    if (requestErrors.length) {
      createFlash({
        message: s__('DORA4Metrics|Something went wrong while getting deployment frequency data.'),
      });

      const allErrorMessages = requestErrors.join('\n');
      Sentry.captureException(
        new Error(
          `Something went wrong while getting deployment frequency data:\n${allErrorMessages}`,
        ),
      );
    }
  },
  areaChartOptions,
  chartDescriptionText,
  chartDocumentationHref,
  environmentTierDocumentationHref,
};
</script>
<template>
  <div>
    <h4 class="gl-my-4">{{ s__('DORA4Metrics|Deployment frequency charts') }}</h4>
    <p data-testid="help-text">
      <gl-sprintf :message="$options.chartDescriptionText">
        <template #link="{ content }">
          <gl-link :href="$options.environmentTierDocumentationHref" target="_blank">{{
            content
          }}</gl-link>
        </template>
      </gl-sprintf>
      <gl-link :href="$options.chartDocumentationHref" target="_blank">
        {{ __('Learn more.') }}
      </gl-link>
    </p>
    <ci-cd-analytics-charts :charts="charts" :chart-options="$options.areaChartOptions" />
  </div>
</template>
