<script>
import { GlLoadingIcon } from '@gitlab/ui';
import createFlash from '~/flash';
import projectsSearch from '../graphql/queries/instance_projects_search.query.graphql';
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
      query: projectsSearch,
      variables() {
        return { pageSize: 1 };
      },
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
  },
};
</script>

<template>
  <security-charts-layout>
    <template v-if="isLoadingProjects" #loading>
      <gl-loading-icon size="lg" class="gl-mt-6" />
    </template>
    <template v-else-if="!projects.length" #empty-state>
      <no-instance-projects />
    </template>
    <template v-else>
      <vulnerability-chart :query="vulnerabilityHistoryQuery" />
      <vulnerability-severities :query="vulnerabilityGradesQuery" />
    </template>
  </security-charts-layout>
</template>
