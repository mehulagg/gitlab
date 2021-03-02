<script>
import { GlLoadingIcon } from '@gitlab/ui';
import createFlash from '~/flash';
import { s__ } from '~/locale';
import projectsQuery from '../graphql/queries/get_instance_security_dashboard_projects.query.graphql';
import vulnerabilityGradesQuery from '../graphql/queries/instance_vulnerability_grades.query.graphql';
import vulnerabilityHistoryQuery from '../graphql/queries/instance_vulnerability_history.query.graphql';
import { createProjectLoadingError } from '../helpers';
import NoInstanceProjects from './empty_states/no_instance_projects.vue';
import VulnerabilityChart from './first_class_vulnerability_chart.vue';
import VulnerabilitySeverities from './first_class_vulnerability_severities.vue';
import SecurityChartsLayout from './security_charts_layout.vue';

export default {
  components: {
    GlLoadingIcon,
    NoInstanceProjects,
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
  i18n: {
    noProjectsMessage: s__(
      'SecurityReports|The security dashboard displays the latest security findings for projects you wish to monitor. Select "Settings" to add and remove projects.',
    ),
  },
};
</script>

<template>
  <security-charts-layout>
    <template v-if="shouldShowEmptyState" #empty-state>
      <no-instance-projects :message="$options.i18n.noProjectsMessage" />
    </template>
    <template v-else-if="shouldShowCharts" #default>
      <vulnerability-chart :query="vulnerabilityHistoryQuery" />
      <vulnerability-severities :query="vulnerabilityGradesQuery" />
    </template>
    <template v-else #loading>
      <gl-loading-icon slot="loading" size="lg" class="gl-mt-6" />
    </template>
  </security-charts-layout>
</template>
