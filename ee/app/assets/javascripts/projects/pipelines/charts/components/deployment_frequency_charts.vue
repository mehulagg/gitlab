<script>
import { GlLink, GlSprintf } from '@gitlab/ui';
import Api from 'ee/api';
import { s__ } from '~/locale';
import createFlash from '~/flash';
import * as Sentry from '~/sentry/wrapper';
import CiCdAnalyticsAreaChart from '~/projects/pipelines/charts/components/ci_cd_analytics_area_chart.vue';
import {
  allChartDefinitions,
  areaChartOptions,
  chartDescriptionText,
  chartDocumentationHref,
} from './static_data';
import { apiDataToChartSeries } from './util';
import { LAST_WEEK, LAST_MONTH, LAST_90_DAYS } from './constants';

export default {
  name: 'DeploymentFrequencyCharts',
  components: {
    GlLink,
    GlSprintf,
    CiCdAnalyticsAreaChart,
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
  async mounted() {
    const results = await Promise.allSettled(
      allChartDefinitions.map(async ({ id, requestParams, startDate }) => {
        const { data: apiData } = await Api.deploymentFrequencies(this.projectPath, requestParams);

        this.chartData[id] = apiDataToChartSeries(apiData, startDate);
      }),
    );

    const requestErrors = results.filter((r) => r.status === 'rejected').map((r) => r.reason);

    if (requestErrors.length) {
      createFlash({
        message: s__(
          'DeploymentFrequencyCharts|Something went wrong while getting deployment frequency data',
        ),
      });

      const allErrorMessages = requestErrors.join('\n');
      Sentry.captureException(
        new Error(
          `Something went wrong while getting deployment frequency data:\n${allErrorMessages}`,
        ),
      );
    }
  },
  allChartDefinitions,
  areaChartOptions,
  chartDescriptionText,
  chartDocumentationHref,
};
</script>
<template>
  <div>
    <h4 class="gl-my-4">{{ s__('DeploymentFrequencyCharts|Deployments charts') }}</h4>
    <p data-testid="help-text">
      <gl-sprintf :message="$options.chartDescriptionText">
        <template #code="{ content }">
          <code>{{ content }}</code>
        </template>
      </gl-sprintf>
      <gl-link :href="$options.chartDocumentationHref">
        {{ __('Learn more.') }}
      </gl-link>
    </p>
    <ci-cd-analytics-area-chart
      v-for="chart of $options.allChartDefinitions"
      :key="chart.id"
      :chart-data="chartData[chart.id]"
      :area-chart-options="$options.areaChartOptions"
    >
      {{ chart.title }}
    </ci-cd-analytics-area-chart>
  </div>
</template>
