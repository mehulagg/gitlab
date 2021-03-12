<script>
import vulnerabilityGradesQuery from '../graphql/queries/instance_vulnerability_grades.query.graphql';
import vulnerabilityHistoryQuery from '../graphql/queries/instance_vulnerability_history.query.graphql';
import DashboardNotConfigured from './empty_states/instance_dashboard_not_configured.vue';
import VulnerabilityChart from './first_class_vulnerability_chart.vue';
import VulnerabilitySeverities from './first_class_vulnerability_severities.vue';
import SecurityChartsLayout from './security_charts_layout.vue';

export default {
  components: {
    DashboardNotConfigured,
    SecurityChartsLayout,
    VulnerabilitySeverities,
    VulnerabilityChart,
  },
  inject: ['hasProjects'],
  queries: {
    history: vulnerabilityHistoryQuery,
    grades: vulnerabilityGradesQuery,
  },
};
</script>

<template>
  <security-charts-layout>
    <template v-if="hasProjects" #default>
      <vulnerability-chart :query="$options.queries.history" />
      <vulnerability-severities :query="$options.queries.grades" />
    </template>

    <template v-else #empty-state>
      <dashboard-not-configured />
    </template>
  </security-charts-layout>
</template>
