<script>
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import Filters from 'ee/security_dashboard/components/first_class_vulnerability_filters.vue';
import projectsQuery from 'ee/security_dashboard/graphql/get_instance_security_dashboard_projects.query.graphql';
import createFlash from '~/flash';
import { createProjectLoadingError } from '../helpers';
import InstanceSecurityVulnerabilities from './first_class_instance_security_dashboard_vulnerabilities.vue';
import CsvExportButton from './csv_export_button.vue';
import DashboardNotConfigured from './empty_states/instance_dashboard_not_configured.vue';
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
  props: {
    vulnerabilitiesExportEndpoint: {
      type: String,
      required: true,
    },
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
};
</script>

<template>
  <security-dashboard-layout>
    <template #header>
      <header class="page-title-holder gl-flex-fill-1 gl-display-flex gl-align-items-center">
        <h2 class="page-title gl-flex-grow-1">{{ s__('SecurityReports|Vulnerability Report') }}</h2>
        <csv-export-button
          v-if="shouldShowDashboard"
          :vulnerabilities-export-endpoint="vulnerabilitiesExportEndpoint"
        />
      </header>
    </template>
    <template #sticky>
      <filters v-if="shouldShowDashboard" :projects="projects" @filterChange="handleFilterChange" />
    </template>
    <vulnerabilities-count-list scope="instance" />
    <instance-security-vulnerabilities
      v-if="shouldShowDashboard"
      :projects="projects"
      :filters="filters"
    />
    <dashboard-not-configured v-else-if="shouldShowEmptyState" />
  </security-dashboard-layout>
</template>
