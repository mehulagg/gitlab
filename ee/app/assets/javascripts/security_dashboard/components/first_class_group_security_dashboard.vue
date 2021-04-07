<script>
import { GlLoadingIcon } from '@gitlab/ui';
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
    GlLoadingIcon,
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
      result() {
        this.projectsWereFetched = true;
      },
      error() {
        this.projectsWereFetched = false;
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
    hasNoProjects() {
      return this.projects.length === 0 && this.projectsWereFetched;
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
  <div>
    <gl-loading-icon v-if="!projectsWereFetched" size="lg" class="gl-mt-6" />
    <dashboard-not-configured v-else-if="hasNoProjects" />
    <security-dashboard-layout v-else>
      <template #header>
        <header class="gl-my-6 gl-display-flex gl-align-items-center">
          <h2 class="gl-flex-grow-1 gl-my-0">
            {{ s__('SecurityReports|Vulnerability Report') }}
          </h2>
          <csv-export-button />
        </header>
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
  </div>
</template>
