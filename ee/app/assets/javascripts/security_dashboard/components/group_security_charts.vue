<script>
import VulnerabilityChart from './first_class_vulnerability_chart.vue';
import VulnerabilitySeverities from './first_class_vulnerability_severities.vue';
import vulnerabilityHistoryQuery from '../graphql/group_vulnerability_history.query.graphql';
import vulnerabilityGradesQuery from '../graphql/group_vulnerability_grades.query.graphql';
import SecurityChartsLayout from './security_charts_layout.vue';

export default {
  components: {
    SecurityChartsLayout,
    VulnerabilitySeverities,
    VulnerabilityChart,
  },
  props: {
    groupFullPath: {
      type: String,
      required: true,
    },
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
    <vulnerability-chart :query="vulnerabilityHistoryQuery" :group-full-path="groupFullPath" />
    <vulnerability-severities :query="vulnerabilityGradesQuery" :group-full-path="groupFullPath" />
  </security-charts-layout>
</template>
