<script>
import { GlTabs, GlTab } from '@gitlab/ui';
import PipelineCharts from './pipeline_charts.vue';

export default {
  components: {
    GlTabs,
    GlTab,
    PipelineCharts,
    DeploymentFrequencyCharts: () =>
      import('ee_component/projects/pipelines/charts/components/deployment_frequency_charts.vue'),
  },
  inject: {
    shouldRenderDeploymentFrequencyCharts: {
      type: Boolean,
      default: false,
    },
  },
};
</script>
<template>
  <div>
    <gl-tabs v-if="shouldRenderDeploymentFrequencyCharts">
      <gl-tab :title="__('Pipelines')">
        <pipeline-charts />
      </gl-tab>
      <gl-tab :title="__('Deployments')">
        <deployment-frequency-charts />
      </gl-tab>
    </gl-tabs>
    <pipeline-charts v-else />
  </div>
</template>
