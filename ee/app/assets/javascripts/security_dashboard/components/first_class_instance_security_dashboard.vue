<script>
import Filters from 'ee/security_dashboard/components/first_class_vulnerability_filters.vue';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import projectsQuery from 'ee/security_dashboard/graphql/queries/get_instance_security_dashboard_projects.query.graphql';
import createFlash from '~/flash';
import { vulnerabilitiesSeverityCountScopes } from '../constants';
import { createProjectLoadingError } from '../helpers';
import CsvExportButton from './csv_export_button.vue';
import DashboardNotConfigured from './empty_states/instance_dashboard_not_configured.vue';
import InstanceSecurityVulnerabilities from './first_class_instance_security_dashboard_vulnerabilities.vue';
import VulnerabilitiesCountList from './vulnerability_count_list.vue';

export default {
  components: {
    CsvExportButton,
    SecurityDashboardLayout,
    InstanceSecurityVulnerabilities,
    Filters,
    DashboardNotConfigured,
    VulnerabilitiesCountList,
  },
  apollo: {
    projects: {
      query: projectsQuery,
      update(data) {
        return data.instanceSecurityDashboard.projects.nodes;
      },
      error() {
        createFlash({ message: createProjectLoadingError() });
      },
    },
  },
  data() {
    return {
      filters: {},
      projects: [],
    };
  },
  computed: {
    isLoadingProjects() {
      return this.$apollo.queries.projects.loading;
    },
    hasProjectsData() {
      return !this.isLoadingProjects && this.projects.length > 0;
    },
    shouldShowDashboard() {
      return this.hasProjectsData;
    },
    shouldShowEmptyState() {
      return !this.isLoadingProjects && this.projects.length === 0;
    },
  },
  methods: {
    handleFilterChange(filters) {
      this.filters = filters;
    },
  },
  vulnerabilitiesSeverityCountScopes,
};
</script>

<template>
  <security-dashboard-layout>
    <dashboard-not-configured v-if="shouldShowEmptyState" />

    <template #header>
      <div v-if="shouldShowDashboard">
        <header class="gl-my-6 gl-display-flex gl-align-items-center" data-testid="header">
          <h2 class="gl-flex-grow-1 gl-my-0">
            {{ s__('SecurityReports|Vulnerability Report') }}
          </h2>
          <csv-export-button />
        </header>
        <vulnerabilities-count-list
          :scope="$options.vulnerabilitiesSeverityCountScopes.instance"
          :filters="filters"
        />
      </div>
    </template>
    <template #sticky>
      <filters v-if="shouldShowDashboard" :projects="projects" @filterChange="handleFilterChange" />
    </template>
    <instance-security-vulnerabilities
      v-if="shouldShowDashboard"
      :projects="projects"
      :filters="filters"
    />
  </security-dashboard-layout>
</template>
