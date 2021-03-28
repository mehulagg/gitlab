<script>
import Cookies from 'js-cookie';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { vulnerabilitiesSeverityCountScopes } from '../constants';
import AutoFixUserCallout from './auto_fix_user_callout.vue';
import CsvExportButton from './csv_export_button.vue';
import ReportsNotConfigured from './empty_states/reports_not_configured.vue';
import Filters from './first_class_vulnerability_filters.vue';
import ProjectPipelineStatus from './project_pipeline_status.vue';
import ProjectVulnerabilitiesApp from './project_vulnerabilities.vue';
import SecurityDashboardLayout from './security_dashboard_layout.vue';
import VulnerabilitiesCountList from './vulnerability_count_list.vue';

export default {
  components: {
    AutoFixUserCallout,
    ProjectPipelineStatus,
    ProjectVulnerabilitiesApp,
    ReportsNotConfigured,
    SecurityDashboardLayout,
    VulnerabilitiesCountList,
    CsvExportButton,
    Filters,
  },
  mixins: [glFeatureFlagsMixin()],
  inject: ['dashboardDocumentation', 'autoFixDocumentation', 'projectFullPath'],
  props: {
    securityDashboardHelpPath: {
      type: String,
      required: true,
    },
    pipeline: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    const shouldShowAutoFixUserCallout =
      this.glFeatures.securityAutoFix && !Cookies.get('auto_fix_user_callout_dismissed');
    return {
      filters: {},
      shouldShowAutoFixUserCallout,
    };
  },
  methods: {
    handleFilterChange(filters) {
      this.filters = filters;
    },
    handleAutoFixUserCalloutClose() {
      Cookies.set('auto_fix_user_callout_dismissed', 'true');
      this.shouldShowAutoFixUserCallout = false;
    },
  },
  vulnerabilitiesSeverityCountScopes,
};
</script>

<template>
  <div v-if="pipeline.id">
    <security-dashboard-layout>
      <template #header>
        <auto-fix-user-callout
          v-if="!shouldShowAutoFixUserCallout"
          :help-page-path="autoFixDocumentation"
          @close="handleAutoFixUserCalloutClose"
        />

        <h4 class="gl-mt-6 gl-display-flex gl-align-items-center">
          {{ s__('SecurityReports|Vulnerability Report') }}
          <csv-export-button class="gl-ml-auto" />
        </h4>
        <project-pipeline-status :pipeline="pipeline" />
        <vulnerabilities-count-list
          class="gl-mt-6"
          :scope="$options.vulnerabilitiesSeverityCountScopes.project"
          :full-path="projectFullPath"
          :filters="filters"
        />
      </template>

      <template #sticky>
        <filters @filterChange="handleFilterChange" />
      </template>

      <project-vulnerabilities-app
        :dashboard-documentation="dashboardDocumentation"
        :filters="filters"
      />
    </security-dashboard-layout>
  </div>
  <reports-not-configured v-else :help-path="securityDashboardHelpPath" />
</template>
