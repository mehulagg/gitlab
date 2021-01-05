<script>
import DeploymentFrequencyChart from './deployment_frequency_chart.vue';

export default {
  name: 'DeploymentFrequencyCharts',
  components: {
    DeploymentFrequencyChart,
  },
  computed: {
    charts() {
      return [];
    },
  },
};
</script>
<template>
  <div>
    <h4 class="gl-my-4">{{ __('Deployments charts') }}</h4>
    <deployment-frequency-chart
      v-for="(chart, index) in charts"
      :key="index"
      :chart-data="chart.data"
    >
      {{ chart.title }}
    </deployment-frequency-chart>
  </div>
</template>
