<script>
import { GlLoadingIcon } from '@gitlab/ui';
import Filters from 'ee/security_dashboard/components/first_class_vulnerability_filters.vue';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import projectsSearch from 'ee/security_dashboard/graphql/queries/instance_projects_search.query.graphql';
import createFlash from '~/flash';
import { vulnerabilitiesSeverityCountScopes } from '../constants';
import { createProjectLoadingError } from '../helpers';
import CsvExportButton from './csv_export_button.vue';
import NoInstanceProjects from './empty_states/no_instance_projects.vue';
import InstanceSecurityVulnerabilities from './first_class_instance_security_dashboard_vulnerabilities.vue';
import VulnerabilitiesCountList from './vulnerability_count_list.vue';

export default {
  components: {
    CsvExportButton,
    SecurityDashboardLayout,
    InstanceSecurityVulnerabilities,
    Filters,
    NoInstanceProjects,
    VulnerabilitiesCountList,
    GlLoadingIcon,
  },
  props: {
    vulnerabilitiesExportEndpoint: {
      type: String,
      required: true,
    },
  },
  apollo: {
    projects: {
      query: projectsSearch,
      variables() {
        return { pageSize: 1 };
      },
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
    shouldShowDashboard() {
      return this.projects.length;
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
    <gl-loading-icon v-if="isLoadingProjects" size="lg" class="gl-mt-6" />
    <no-instance-projects v-else-if="!shouldShowDashboard" />

    <template #header>
      <div v-if="shouldShowDashboard">
        <header class="gl-my-6 gl-display-flex gl-align-items-center">
          <h2 class="gl-flex-grow-1 gl-my-0">
            {{ s__('SecurityReports|Vulnerability Report') }}
          </h2>
          <csv-export-button :vulnerabilities-export-endpoint="vulnerabilitiesExportEndpoint" />
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
    <instance-security-vulnerabilities v-if="shouldShowDashboard" :filters="filters" />
  </security-dashboard-layout>
</template>
