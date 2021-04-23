<script>
import { GlLoadingIcon } from '@gitlab/ui';
import createFlash from '~/flash';
import vulnerabilityGradesQuery from '../graphql/queries/group_vulnerability_grades.query.graphql';
import vulnerabilityHistoryQuery from '../graphql/queries/group_vulnerability_history.query.graphql';
import groupProjectsQuery from '../graphql/queries/vulnerable_projects_group.query.graphql';
import { PROJECT_LOADING_ERROR_MESSAGE } from '../helpers';
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
  inject: ['groupFullPath'],
  apollo: {
    projects: {
      query: groupProjectsQuery,
      variables() {
        return { fullPath: this.groupFullPath };
      },
      update(data) {
        return data?.group?.projects?.nodes ?? [];
      },
      error() {
        createFlash({ message: PROJECT_LOADING_ERROR_MESSAGE });
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
