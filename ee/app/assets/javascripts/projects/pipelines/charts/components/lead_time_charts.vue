<script>
import * as DoraApi from 'ee/api/dora_api';

export default {
  name: 'LeadTimeCharts',
  async mounted() {
    const results = await Promise.allSettled(
      allChartDefinitions.map(async ({ id, requestParams, startDate, endDate }) => {
        const { data: apiData } = await DoraApi.getProjectDoraMetrics(
          this.projectPath,
          DoraApi.LEAD_TIME_FOR_CHANGES,
          requestParams,
        );

        this.chartData[id] = apiDataToChartSeries(apiData, startDate, endDate);
      }),
    );
  },
};
</script>
<template>
  <div>
    <h4 class="gl-my-4">{{ s__('DORA4|Lead time charts') }}</h4>
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
    <ci-cd-analytics-charts :charts="charts" :chart-options="$options.areaChartOptions" />
  </div>
</template>
