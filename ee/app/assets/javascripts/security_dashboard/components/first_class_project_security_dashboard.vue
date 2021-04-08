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
import SurveyRequestBanner from './survey_request_banner.vue';
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
    SurveyRequestBanner,
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
  <div>
    <survey-request-banner class="gl-mt-5" />

    <template v-if="pipeline.id">
      <auto-fix-user-callout
        v-if="shouldShowAutoFixUserCallout"
        :help-page-path="autoFixDocumentation"
        @close="handleAutoFixUserCalloutClose"
      />
      <security-dashboard-layout>
        <template #header>
          <div class="gl-mt-6 gl-display-flex">
            <h4 class="gl-flex-grow-1 gl-my-0">
              {{ s__('SecurityReports|Vulnerability Report') }}
            </h4>
            <csv-export-button />
          </div>
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
    </template>
    <reports-not-configured v-else :help-path="securityDashboardHelpPath" />
  </div>
</template>
