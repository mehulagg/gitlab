<script>
import GroupSecurityVulnerabilities from 'ee/security_dashboard/components/first_class_group_security_dashboard_vulnerabilities.vue';
import Filters from 'ee/security_dashboard/components/first_class_vulnerability_filters.vue';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import { vulnerabilitiesSeverityCountScopes } from '../constants';
import vulnerableProjectsQuery from '../graphql/queries/vulnerable_projects.query.graphql';
import CsvExportButton from './csv_export_button.vue';
import DashboardNotConfigured from './empty_states/group_dashboard_not_configured.vue';
import VulnerabilitiesCountList from './vulnerability_count_list.vue';

export default {
  components: {
    SecurityDashboardLayout,
    GroupSecurityVulnerabilities,
    Filters,
    CsvExportButton,
    DashboardNotConfigured,
    VulnerabilitiesCountList,
  },
  inject: ['groupFullPath'],
  apollo: {
    projects: {
      query: vulnerableProjectsQuery,
      variables() {
        return { fullPath: this.groupFullPath };
      },
      update(data) {
        return data.group.projects.nodes;
      },
    },
  },
  data() {
    return {
      filters: {},
      projects: [],
      projectsWereFetched: false,
    };
  },
  computed: {
    isLoadingProjects() {
      return this.$apollo.queries.projects.loading;
    },
    hasNoProjects() {
      return this.projects.length === 0;
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
  <security-dashboard-layout :is-loading="isLoadingProjects">
    <dashboard-not-configured v-if="hasNoProjects" />
    <template v-else #header>
      <h2 class="gl-my-6 gl-display-flex gl-align-items-center">
        {{ s__('SecurityReports|Vulnerability Report') }}
        <csv-export-button class="gl-ml-auto" />
      </h2>
      <vulnerabilities-count-list
        :scope="$options.vulnerabilitiesSeverityCountScopes.group"
        :full-path="groupFullPath"
        :filters="filters"
      />
    </template>

    <template #sticky>
      <filters :projects="projects" @filterChange="handleFilterChange" />
    </template>

    <group-security-vulnerabilities :filters="filters" />
  </security-dashboard-layout>
</template>
