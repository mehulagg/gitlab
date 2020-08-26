<script>
import SecurityChartsLayout from './security_charts_layout.vue';
import VulnerabilityChart from './first_class_vulnerability_chart.vue';
import VulnerabilitySeverities from './first_class_vulnerability_severities.vue';
import vulnerabilityHistoryQuery from '../graphql/instance_vulnerability_history.query.graphql';
import vulnerabilityGradesQuery from '../graphql/instance_vulnerability_grades.query.graphql';

export default {
  components: {
    SecurityChartsLayout,
    VulnerabilitySeverities,
    VulnerabilityChart,
  },
  data() {
    return {
      vulnerabilityHistoryQuery,
      vulnerabilityGradesQuery,
    };
  },

  emits: [],
};
</script>

<template>
  <security-charts-layout>
    <vulnerability-chart :query="vulnerabilityHistoryQuery" />
    <vulnerability-severities :query="vulnerabilityGradesQuery" />
  </security-charts-layout>
</template>
