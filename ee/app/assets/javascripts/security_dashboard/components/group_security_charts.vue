<script>
import { GlLoadingIcon } from '@gitlab/ui';
import createFlash from '~/flash';
import { createProjectLoadingError } from '../helpers';
import vulnerabilityHistoryQuery from '../graphql/queries/group_vulnerability_history.query.graphql';
import vulnerabilityGradesQuery from '../graphql/queries/group_vulnerability_grades.query.graphql';
import vulnerableProjectsQuery from '../graphql/queries/vulnerable_projects.query.graphql';
import DashboardNotConfigured from './empty_states/group_dashboard_not_configured.vue';
import SecurityChartsLayout from './security_charts_layout.vue';
import VulnerabilityChart from './first_class_vulnerability_chart.vue';
import VulnerabilitySeverities from './first_class_vulnerability_severities.vue';

export default {
  components: {
    GlLoadingIcon,
    DashboardNotConfigured,
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
  apollo: {
    projects: {
      query: vulnerableProjectsQuery,
      variables() {
        return { fullPath: this.groupFullPath };
      },
      update(data) {
        return data?.group?.projects?.nodes ?? [];
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
      <vulnerability-chart :query="vulnerabilityHistoryQuery" :group-full-path="groupFullPath" />
      <vulnerability-severities
        :query="vulnerabilityGradesQuery"
        :group-full-path="groupFullPath"
      />
    </template>
    <template v-else #loading>
      <gl-loading-icon size="lg" class="gl-mt-6" />
    </template>
  </security-charts-layout>
</template>
