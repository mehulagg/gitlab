<script>
import { GlLoadingIcon } from '@gitlab/ui';
import createFlash from '~/flash';
import { createProjectLoadingError } from '../helpers';
import DashboardNotConfigured from './empty_states/instance_dashboard_not_configured.vue';
import SecurityChartsLayout from './security_charts_layout.vue';
import VulnerabilityChart from './first_class_vulnerability_chart.vue';
import VulnerabilitySeverities from './first_class_vulnerability_severities.vue';
import projectsQuery from '../graphql/queries/get_instance_security_dashboard_projects.query.graphql';
import vulnerabilityHistoryQuery from '../graphql/queries/instance_vulnerability_history.query.graphql';
import vulnerabilityGradesQuery from '../graphql/queries/instance_vulnerability_grades.query.graphql';

export default {
  components: {
    GlLoadingIcon,
    DashboardNotConfigured,
    SecurityChartsLayout,
    VulnerabilitySeverities,
    VulnerabilityChart,
  },
  apollo: {
    projects: {
      query: projectsQuery,
      update(data) {
        return data?.instanceSecurityDashboard?.projects?.nodes ?? [];
      },
      error() {
        createFlash({ message: createProjectLoadingError() });
      },
    },
  },
  data() {
    return {
      projects: [],
      vulnerabilityHistoryQuery,
      vulnerabilityGradesQuery,
    };
  },
  computed: {
    isLoadingProjects() {
      return this.$apollo.queries.projects.loading;
    },
    shouldShowCharts() {
      return Boolean(!this.isLoadingProjects && this.projects.length);
    },
    shouldShowEmptyState() {
      return !this.isLoadingProjects && !this.projects.length;
    },
  },
};
</script>

<template>
  <security-charts-layout>
    <template v-if="shouldShowEmptyState" #empty-state>
      <dashboard-not-configured />
    </template>
    <template v-else-if="shouldShowCharts" #default>
      <vulnerability-chart :query="vulnerabilityHistoryQuery" />
      <vulnerability-severities :query="vulnerabilityGradesQuery" />
    </template>
    <template v-else #loading>
      <gl-loading-icon size="lg" class="gl-mt-6" />
    </template>
  </security-charts-layout>
</template>
