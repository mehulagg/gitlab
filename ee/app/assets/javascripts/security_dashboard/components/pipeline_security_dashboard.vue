<script>
import { mapActions } from 'vuex';
import { GlEmptyState } from '@gitlab/ui';
import { s__ } from '~/locale';
import { fetchPolicies } from '~/lib/graphql';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import pipelineSecurityReportSummaryQuery from '../graphql/queries/pipeline_security_report_summary.query.graphql';
import SecurityReportsSummary from './security_reports_summary.vue';
import SecurityDashboard from './security_dashboard_vuex.vue';

export default {
  name: 'PipelineSecurityDashboard',
  components: {
    GlEmptyState,
    SecurityReportsSummary,
    SecurityDashboard,
  },
  mixins: [glFeatureFlagsMixin()],
  apollo: {
    securityReportSummary: {
      query: pipelineSecurityReportSummaryQuery,
      fetchPolicy: fetchPolicies.NETWORK_ONLY,
      variables() {
        return {
          fullPath: this.projectFullPath,
          pipelineIid: this.pipelineIid,
        };
      },
      update(data) {
        const summary = data?.project?.pipeline?.securityReportSummary;
        return summary && Object.keys(summary).length ? summary : null;
      },
      skip() {
        return !this.glFeatures.pipelinesSecurityReportSummary;
      },
    },
  },
  props: {
    dashboardDocumentation: {
      type: String,
      required: true,
    },
    emptyStateSvgPath: {
      type: String,
      required: true,
    },
    pipelineId: {
      type: Number,
      required: true,
    },
    pipelineIid: {
      type: Number,
      required: true,
    },
    projectId: {
      type: Number,
      required: true,
    },
    sourceBranch: {
      type: String,
      required: true,
    },
    vulnerabilitiesEndpoint: {
      type: String,
      required: true,
    },
    loadingErrorIllustrations: {
      type: Object,
      required: true,
    },
    projectFullPath: {
      type: String,
      required: false,
      default: '',
    },
    pipelineJobsPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    emptyStateProps() {
      return {
        svgPath: this.emptyStateSvgPath,
        title: s__('SecurityReports|No vulnerabilities found for this pipeline'),
        description: s__(
          `SecurityReports|While it's rare to have no vulnerabilities for your pipeline, it can happen. In any event, we ask that you double check your settings to make sure all security scanning jobs have passed successfully.`,
        ),
        primaryButtonLink: this.dashboardDocumentation,
        primaryButtonText: s__('SecurityReports|Learn more about setting up your dashboard'),
      };
    },
  },
  created() {
    this.setSourceBranch(this.sourceBranch);
    this.setPipelineJobsPath(this.pipelineJobsPath);
    this.setProjectId(this.projectId);
  },
  methods: {
    ...mapActions('vulnerabilities', ['setSourceBranch']),
    ...mapActions('pipelineJobs', ['setPipelineJobsPath', 'setProjectId']),
  },
};
</script>

<template>
  <div>
    <security-reports-summary
      v-if="securityReportSummary"
      :summary="securityReportSummary"
      class="gl-my-5"
    />
    <security-dashboard
      :vulnerabilities-endpoint="vulnerabilitiesEndpoint"
      :lock-to-project="{ id: projectId }"
      :pipeline-id="pipelineId"
      :loading-error-illustrations="loadingErrorIllustrations"
      :security-report-summary="securityReportSummary"
    >
      <template #empty-state>
        <gl-empty-state v-bind="emptyStateProps" />
      </template>
    </security-dashboard>
  </div>
</template>
