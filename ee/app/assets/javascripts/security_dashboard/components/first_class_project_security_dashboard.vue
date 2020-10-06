<script>
import ProjectPipelineStatus from './project_pipeline_status.vue';
import ProjectVulnerabilitiesApp from './project_vulnerabilities.vue';
import ReportsNotConfigured from './empty_states/reports_not_configured.vue';
import SecurityDashboardLayout from './security_dashboard_layout.vue';
import VulnerabilitiesCountList from './vulnerability_count_list.vue';
import Filters from './first_class_vulnerability_filters.vue';
import CsvExportButton from './csv_export_button.vue';

export const BANNER_COOKIE_KEY = 'hide_vulnerabilities_introduction_banner';

export default {
  components: {
    ProjectPipelineStatus,
    ProjectVulnerabilitiesApp,
    ReportsNotConfigured,
    SecurityDashboardLayout,
    VulnerabilitiesCountList,
    CsvExportButton,
    Filters,
  },
  props: {
    securityDashboardHelpPath: {
      type: String,
      required: true,
    },
    projectFullPath: {
      type: String,
      required: false,
      default: '',
    },
    hasVulnerabilities: {
      type: Boolean,
      required: false,
      default: false,
    },
    vulnerabilitiesExportEndpoint: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      filters: {},
    };
  },
  inject: ['dashboardDocumentation'],
  methods: {
    handleFilterChange(filters) {
      this.filters = filters;
    },
  },
};
</script>

<template>
  <div>
    <template v-if="hasVulnerabilities">
      <security-dashboard-layout>
        <template #header>
          <div class="mt-4 d-flex">
            <h4 class="flex-grow mt-0 mb-0">{{ __('Vulnerabilities') }}</h4>
            <csv-export-button :vulnerabilities-export-endpoint="vulnerabilitiesExportEndpoint" />
          </div>
          <project-pipeline-status :project-full-path="projectFullPath" />
          <vulnerabilities-count-list :project-full-path="projectFullPath" :filters="filters" />
        </template>
        <template #sticky>
          <filters @filterChange="handleFilterChange" />
        </template>
        <project-vulnerabilities-app
          :dashboard-documentation="dashboardDocumentation"
          :project-full-path="projectFullPath"
          :filters="filters"
        />
      </security-dashboard-layout>
    </template>
    <reports-not-configured v-else :help-path="securityDashboardHelpPath" />
  </div>
</template>
