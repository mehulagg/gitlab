<script>
import { GlLoadingIcon } from '@gitlab/ui';
import GroupSecurityVulnerabilities from 'ee/security_dashboard/components/first_class_group_security_dashboard_vulnerabilities.vue';
import Filters from 'ee/security_dashboard/components/first_class_vulnerability_filters.vue';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import createFlash from '~/flash';
import { vulnerabilitiesSeverityCountScopes } from '../constants';
import groupProjectsSearch from '../graphql/queries/group_projects_search.query.graphql';
import { createProjectLoadingError } from '../helpers';
import CsvExportButton from './csv_export_button.vue';
import NoGroupProjects from './empty_states/no_group_projects.vue';
import VulnerabilitiesCountList from './vulnerability_count_list.vue';

export default {
  components: {
    SecurityDashboardLayout,
    GroupSecurityVulnerabilities,
    Filters,
    CsvExportButton,
    NoGroupProjects,
    GlLoadingIcon,
    VulnerabilitiesCountList,
  },
  props: {
    groupFullPath: {
      type: String,
      required: true,
    },
    vulnerabilitiesExportEndpoint: {
      type: String,
      required: true,
    },
  },
  apollo: {
    projects: {
      query: groupProjectsSearch,
      variables() {
        return {
          fullPath: this.groupFullPath,
          pageSize: 1,
        };
      },
      update(data) {
        return data.group.projects.nodes;
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
      projectsWereFetched: false,
    };
  },
  computed: {
    isLoadingProjects() {
      return this.$apollo.queries.projects.loading;
    },
    hasNoProjects() {
      return this.projects.length <= 0;
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
    <gl-loading-icon v-if="isLoadingProjects" size="lg" class="gl-mt-6" />
    <no-group-projects v-else-if="hasNoProjects" />
    <security-dashboard-layout v-else>
      <template #header>
        <header class="gl-my-6 gl-display-flex gl-align-items-center">
          <h2 class="gl-flex-grow-1 gl-my-0">
            {{ s__('SecurityReports|Vulnerability Report') }}
          </h2>
          <csv-export-button :vulnerabilities-export-endpoint="vulnerabilitiesExportEndpoint" />
        </header>
        <vulnerabilities-count-list
          :scope="$options.vulnerabilitiesSeverityCountScopes.group"
          :full-path="groupFullPath"
          :filters="filters"
        />
      </template>
      <template #sticky>
        <filters @filterChange="handleFilterChange" />
      </template>
      <group-security-vulnerabilities :group-full-path="groupFullPath" :filters="filters" />
    </security-dashboard-layout>
  </div>
</template>
