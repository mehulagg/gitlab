<script>
import vulnerabilityGradesQuery from '../graphql/queries/group_vulnerability_grades.query.graphql';
import vulnerabilityHistoryQuery from '../graphql/queries/group_vulnerability_history.query.graphql';
import DashboardNotConfigured from './empty_states/group_dashboard_not_configured.vue';
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
  props: {
    groupFullPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      projects: [],
      vulnerabilityHistoryQuery,
      vulnerabilityGradesQuery,
    };
  },
};
</script>

<template>
  <security-charts-layout>
    <template v-if="hasProjects" #default>
      <vulnerability-chart :query="vulnerabilityHistoryQuery" :group-full-path="groupFullPath" />
      <vulnerability-severities
        :query="vulnerabilityGradesQuery"
        :group-full-path="groupFullPath"
      />
    </template>

    <template v-else #empty-state>
      <dashboard-not-configured />
    </template>
  </security-charts-layout>
</template>
