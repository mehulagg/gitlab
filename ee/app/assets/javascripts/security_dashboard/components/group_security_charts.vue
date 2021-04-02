<script>
import { GlLoadingIcon } from '@gitlab/ui';
import vulnerabilityGradesQuery from '../graphql/queries/group_vulnerability_grades.query.graphql';
import vulnerabilityHistoryQuery from '../graphql/queries/group_vulnerability_history.query.graphql';
import DashboardNotConfigured from './empty_states/group_dashboard_not_configured.vue';
import VulnerabilityChart from './first_class_vulnerability_chart.vue';
import VulnerabilitySeverities from './first_class_vulnerability_severities.vue';
import SecurityChartsLayout from './security_charts_layout.vue';

export default {
  components: {
    GlLoadingIcon,
    DashboardNotConfigured,
    SecurityChartsLayout,
    VulnerabilitySeverities,
    VulnerabilityChart,
  },
  inject: ['groupFullPath', 'hasProjects'],
  vulnerabilityHistoryQuery,
  vulnerabilityGradesQuery,
};
</script>

<template>
  <security-charts-layout>
    <template v-if="shouldShowEmptyState" #empty-state>
      <dashboard-not-configured />
    </template>
    <template v-else-if="shouldShowCharts" #default>
      <vulnerability-chart :query="$options.vulnerabilityHistoryQuery" />
      <vulnerability-severities :query="$options.vulnerabilityGradesQuery" />
    </template>
    <template v-else #loading>
      <gl-loading-icon size="lg" class="gl-mt-6" />
    </template>
  </security-charts-layout>
</template>
