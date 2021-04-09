<script>
import { GlLoadingIcon } from '@gitlab/ui';
import Filters from 'ee/security_dashboard/components/first_class_vulnerability_filters.vue';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import instanceProjectsQuery from 'ee/security_dashboard/graphql/queries/instance_projects.query.graphql';
import createFlash from '~/flash';
import { vulnerabilitiesSeverityCountScopes } from '../constants';
import { PROJECT_LOADING_ERROR_MESSAGE } from '../helpers';
import CsvExportButton from './csv_export_button.vue';
import DashboardNotConfigured from './empty_states/instance_dashboard_not_configured.vue';
import InstanceSecurityVulnerabilities from './first_class_instance_security_dashboard_vulnerabilities.vue';
import SurveyRequestBanner from './survey_request_banner.vue';
import VulnerabilitiesCountList from './vulnerability_count_list.vue';

export default {
  components: {
    CsvExportButton,
    SecurityDashboardLayout,
    InstanceSecurityVulnerabilities,
    Filters,
    DashboardNotConfigured,
    VulnerabilitiesCountList,
    SurveyRequestBanner,
    GlLoadingIcon,
  },
  apollo: {
    projects: {
      query: instanceProjectsQuery,
      update(data) {
        return data.instanceSecurityDashboard.projects.nodes;
      },
      error() {
        createFlash({ message: PROJECT_LOADING_ERROR_MESSAGE });
      },
    },
  },
  data() {
    return {
      filters: null,
      projects: [],
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
  <gl-loading-icon v-if="isLoadingProjects" size="lg" class="gl-mt-6" />

  <div v-else-if="hasNoProjects">
    <survey-request-banner class="gl-mt-5" />
    <dashboard-not-configured />
  </div>

  <security-dashboard-layout v-else>
    <template #header>
      <survey-request-banner class="gl-mt-5" />

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
    </template>

    <template #sticky>
      <filters :projects="projects" @filterChange="handleFilterChange" />
    </template>

    <instance-security-vulnerabilities :projects="projects" :filters="filters" />
  </security-dashboard-layout>
</template>
