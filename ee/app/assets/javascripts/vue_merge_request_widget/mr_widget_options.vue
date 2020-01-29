<script>
import { isNumber, isString } from 'lodash';
import GroupedSecurityReportsApp from 'ee/vue_shared/security_reports/grouped_security_reports_app.vue';
import GroupedMetricsReportsApp from 'ee/vue_shared/metrics_reports/grouped_metrics_reports_app.vue';
import reportsMixin from 'ee/vue_shared/security_reports/mixins/reports_mixin';
import { componentNames } from 'ee/reports/components/issue_body';
import MrWidgetLicenses from 'ee/vue_shared/license_management/mr_widget_license_report.vue';
import ReportSection from '~/reports/components/report_section.vue';
import BlockingMergeRequestsReport from './components/blocking_merge_requests/blocking_merge_requests_report.vue';

import { n__, s__, __, sprintf } from '~/locale';
import CEWidgetOptions from '~/vue_merge_request_widget/mr_widget_options.vue';
import MrWidgetApprovals from './components/approvals/approvals.vue';
import MrWidgetGeoSecondaryNode from './components/states/mr_widget_secondary_geo_node.vue';
import MergeTrainHelperText from './components/merge_train_helper_text.vue';
import { MTWPS_MERGE_STRATEGY } from '~/vue_merge_request_widget/constants';

export default {
  components: {
    MergeTrainHelperText,
    MrWidgetLicenses,
    MrWidgetApprovals,
    MrWidgetGeoSecondaryNode,
    BlockingMergeRequestsReport,
    GroupedSecurityReportsApp,
    GroupedMetricsReportsApp,
    ReportSection,
  },
  extends: CEWidgetOptions,
  mixins: [reportsMixin],
  componentNames,
  data() {
    return {
      isLoadingCodequality: false,
      isLoadingPerformance: false,
      loadingCodequalityFailed: false,
      loadingPerformanceFailed: false,
      loadingLicenseReportFailed: false,
    };
  },
  computed: {
    shouldRenderApprovals() {
      return this.mr.hasApprovalsAvailable && this.mr.state !== 'nothingToMerge';
    },
    shouldRenderCodeQuality() {
      const { codeclimate } = this.mr || {};
      return codeclimate && codeclimate.head_path;
    },
    shouldRenderLicenseReport() {
      return this.mr.enabledReports?.licenseManagement;
    },
    hasCodequalityIssues() {
      return (
        this.mr.codeclimateMetrics &&
        ((this.mr.codeclimateMetrics.newIssues &&
          this.mr.codeclimateMetrics.newIssues.length > 0) ||
          (this.mr.codeclimateMetrics.resolvedIssues &&
            this.mr.codeclimateMetrics.resolvedIssues.length > 0))
      );
    },
    hasPerformanceMetrics() {
      return (
        this.mr.performanceMetrics &&
        ((this.mr.performanceMetrics.degraded && this.mr.performanceMetrics.degraded.length > 0) ||
          (this.mr.performanceMetrics.improved && this.mr.performanceMetrics.improved.length > 0))
      );
    },
    shouldRenderPerformance() {
      const { performance } = this.mr || {};
      return performance && performance.head_path && performance.base_path;
    },
    shouldRenderSecurityReport() {
      const { enabledReports } = this.mr;
      return (
        enabledReports &&
        this.$options.securityReportTypes.some(reportType => enabledReports[reportType])
      );
    },
    codequalityText() {
      const { newIssues, resolvedIssues } = this.mr.codeclimateMetrics;
      const text = [];

      if (!newIssues.length && !resolvedIssues.length) {
        text.push(s__('ciReport|No changes to code quality'));
      } else if (newIssues.length || resolvedIssues.length) {
        text.push(s__('ciReport|Code quality'));

        if (resolvedIssues.length) {
          text.push(n__(' improved on %d point', ' improved on %d points', resolvedIssues.length));
        }

        if (newIssues.length > 0 && resolvedIssues.length > 0) {
          text.push(__(' and'));
        }

        if (newIssues.length) {
          text.push(n__(' degraded on %d point', ' degraded on %d points', newIssues.length));
        }
      }

      return text.join('');
    },
    codequalityPopover() {
      const { codeclimate } = this.mr || {};
      if (codeclimate && !codeclimate.base_path) {
        return {
          title: s__('ciReport|Base pipeline codequality artifact not found'),
          content: sprintf(
            s__('ciReport|%{linkStartTag}Learn more about codequality reports %{linkEndTag}'),
            {
              linkStartTag: `<a href="${this.mr.codequalityHelpPath}" target="_blank" rel="noopener noreferrer">`,
              linkEndTag: '<i class="fa fa-external-link" aria-hidden="true"></i></a>',
            },
            false,
          ),
        };
      }
      return {};
    },

    performanceText() {
      const { improved, degraded } = this.mr.performanceMetrics;
      const text = [];

      if (!improved.length && !degraded.length) {
        text.push(s__('ciReport|No changes to performance metrics'));
      } else if (improved.length || degraded.length) {
        text.push(s__('ciReport|Performance metrics'));

        if (improved.length) {
          text.push(n__(' improved on %d point', ' improved on %d points', improved.length));
        }

        if (improved.length > 0 && degraded.length > 0) {
          text.push(__(' and'));
        }

        if (degraded.length) {
          text.push(n__(' degraded on %d point', ' degraded on %d points', degraded.length));
        }
      }

      return text.join('');
    },

    codequalityStatus() {
      return this.checkReportStatus(this.isLoadingCodequality, this.loadingCodequalityFailed);
    },

    performanceStatus() {
      return this.checkReportStatus(this.isLoadingPerformance, this.loadingPerformanceFailed);
    },

    shouldRenderMergeTrainHelperText() {
      return (
        this.mr.pipeline &&
        isNumber(this.mr.pipeline.id) &&
        isString(this.mr.pipeline.path) &&
        this.mr.preferredMergeStrategy === MTWPS_MERGE_STRATEGY &&
        !this.mr.autoMergeEnabled
      );
    },
    licensesApiPath() {
      return (gl && gl.mrWidgetData && gl.mrWidgetData.license_management_comparison_path) || null;
    },
  },
  watch: {
    shouldRenderCodeQuality(newVal) {
      if (newVal) {
        this.fetchCodeQuality();
      }
    },
    shouldRenderPerformance(newVal) {
      if (newVal) {
        this.fetchPerformance();
      }
    },
  },
  methods: {
    getServiceEndpoints(store) {
      const base = CEWidgetOptions.methods.getServiceEndpoints(store);

      return {
        ...base,
        apiApprovalsPath: store.apiApprovalsPath,
        apiApprovalSettingsPath: store.apiApprovalSettingsPath,
        apiApprovePath: store.apiApprovePath,
        apiUnapprovePath: store.apiUnapprovePath,
      };
    },
    fetchCodeQuality() {
      const { codeclimate } = this.mr || {};

      if (!codeclimate.base_path) {
        this.isLoadingCodequality = false;
        this.loadingCodequalityFailed = true;
        return;
      }

      this.isLoadingCodequality = true;

      Promise.all([
        this.service.fetchReport(codeclimate.head_path),
        this.service.fetchReport(codeclimate.base_path),
      ])
        .then(values =>
          this.mr.compareCodeclimateMetrics(
            values[0],
            values[1],
            this.mr.headBlobPath,
            this.mr.baseBlobPath,
          ),
        )
        .then(() => {
          this.isLoadingCodequality = false;
        })
        .catch(() => {
          this.isLoadingCodequality = false;
          this.loadingCodequalityFailed = true;
        });
    },

    fetchPerformance() {
      const { head_path, base_path } = this.mr.performance;

      this.isLoadingPerformance = true;

      Promise.all([this.service.fetchReport(head_path), this.service.fetchReport(base_path)])
        .then(values => {
          this.mr.comparePerformanceMetrics(values[0], values[1]);
          this.isLoadingPerformance = false;
        })
        .catch(() => {
          this.isLoadingPerformance = false;
          this.loadingPerformanceFailed = true;
        });
    },

    translateText(type) {
      return {
        error: sprintf(s__('ciReport|Failed to load %{reportName} report'), {
          reportName: type,
        }),
        loading: sprintf(s__('ciReport|Loading %{reportName} report'), {
          reportName: type,
        }),
      };
    },
  },
  securityReportTypes: ['dast', 'sast', 'dependencyScanning', 'containerScanning'],
};
</script>
<template>
  <div v-if="mr" class="mr-state-widget prepend-top-default">
    <mr-widget-header :mr="mr" />
    <mr-widget-suggest-pipeline
      v-if="shouldSuggestPipelines"
      class="mr-widget-workflow"
      :pipeline-path="mr.mergeRequestAddCiConfigPath"
      :pipeline-svg-path="mr.pipelinesEmptySvgPath"
      :human-access="mr.humanAccess.toLowerCase()"
    />
    <mr-widget-pipeline-container
      v-if="shouldRenderPipelines"
      class="mr-widget-workflow"
      :mr="mr"
    />
    <mr-widget-approvals
      v-if="shouldRenderApprovals"
      class="mr-widget-workflow"
      :mr="mr"
      :service="service"
    />
    <div class="mr-section-container mr-widget-workflow">
      <blocking-merge-requests-report :mr="mr" />
      <report-section
        v-if="shouldRenderCodeQuality"
        :status="codequalityStatus"
        :loading-text="translateText('codeclimate').loading"
        :error-text="translateText('codeclimate').error"
        :success-text="codequalityText"
        :unresolved-issues="mr.codeclimateMetrics.newIssues"
        :resolved-issues="mr.codeclimateMetrics.resolvedIssues"
        :has-issues="hasCodequalityIssues"
        :component="$options.componentNames.CodequalityIssueBody"
        :popover-options="codequalityPopover"
        class="js-codequality-widget mr-widget-border-top mr-report"
      />
      <report-section
        v-if="shouldRenderPerformance"
        :status="performanceStatus"
        :loading-text="translateText('performance').loading"
        :error-text="translateText('performance').error"
        :success-text="performanceText"
        :unresolved-issues="mr.performanceMetrics.degraded"
        :resolved-issues="mr.performanceMetrics.improved"
        :has-issues="hasPerformanceMetrics"
        :component="$options.componentNames.PerformanceIssueBody"
        class="js-performance-widget mr-widget-border-top mr-report"
      />
      <grouped-metrics-reports-app
        v-if="mr.metricsReportsPath"
        :endpoint="mr.metricsReportsPath"
        class="js-metrics-reports-container"
      />
      <grouped-security-reports-app
        v-if="shouldRenderSecurityReport"
        :head-blob-path="mr.headBlobPath"
        :source-branch="mr.sourceBranch"
        :target-branch="mr.targetBranch"
        :base-blob-path="mr.baseBlobPath"
        :enabled-reports="mr.enabledReports"
        :sast-help-path="mr.sastHelp"
        :dast-help-path="mr.dastHelp"
        :container-scanning-help-path="mr.containerScanningHelp"
        :dependency-scanning-help-path="mr.dependencyScanningHelp"
        :vulnerability-feedback-path="mr.vulnerabilityFeedbackPath"
        :vulnerability-feedback-help-path="mr.vulnerabilityFeedbackHelpPath"
        :create-vulnerability-feedback-issue-path="mr.createVulnerabilityFeedbackIssuePath"
        :create-vulnerability-feedback-merge-request-path="
          mr.createVulnerabilityFeedbackMergeRequestPath
        "
        :create-vulnerability-feedback-dismissal-path="mr.createVulnerabilityFeedbackDismissalPath"
        :pipeline-path="mr.pipeline.path"
        :pipeline-id="mr.securityReportsPipelineId"
        :diverged-commits-count="mr.divergedCommitsCount"
        :mr-state="mr.state"
        :target-branch-tree-path="mr.targetBranchTreePath"
        :new-pipeline-path="mr.newPipelinePath"
        class="js-security-widget"
      />
      <mr-widget-licenses
        v-if="shouldRenderLicenseReport"
        :api-url="mr.licenseManagement.managed_licenses_path"
        :licenses-api-path="licensesApiPath"
        :pipeline-path="mr.pipeline.path"
        :can-manage-licenses="mr.licenseManagement.can_manage_licenses"
        :full-report-path="mr.licenseManagement.license_management_full_report_path"
        :license-management-settings-path="mr.licenseManagement.license_management_settings_path"
        :security-approvals-help-page-path="mr.securityApprovalsHelpPagePath"
        report-section-class="mr-widget-border-top"
      />
      <grouped-test-reports-app
        v-if="mr.testResultsPath"
        class="js-reports-container"
        :endpoint="mr.testResultsPath"
      />
      <div class="mr-widget-section">
        <component :is="componentName" :mr="mr" :service="service" />

        <div class="mr-widget-info">
          <section v-if="mr.allowCollaboration" class="mr-info-list mr-links">
            <p>
              {{ s__('mrWidget|Allows commits from members who can merge to the target branch') }}
            </p>
          </section>

          <mr-widget-related-links
            v-if="shouldRenderRelatedLinks"
            :state="mr.state"
            :related-links="mr.relatedLinks"
          />

          <mr-widget-alert-message
            v-if="showMergePipelineForkWarning"
            type="warning"
            :help-path="mr.mergeRequestPipelinesHelpPath"
          >
            {{
              s__(
                'mrWidget|Fork merge requests do not create merge request pipelines which validate a post merge result',
              )
            }}
          </mr-widget-alert-message>

          <mr-widget-alert-message v-if="mr.mergeError" type="danger">
            {{ mergeError }}
          </mr-widget-alert-message>

          <source-branch-removal-status v-if="shouldRenderSourceBranchRemovalStatus" />
        </div>
      </div>
      <merge-train-helper-text
        v-if="shouldRenderMergeTrainHelperText"
        :pipeline-id="mr.pipeline.id"
        :pipeline-link="mr.pipeline.path"
        :merge-train-length="mr.mergeTrainsCount"
        :merge-train-when-pipeline-succeeds-docs-path="mr.mergeTrainWhenPipelineSucceedsDocsPath"
      />
      <div v-if="shouldRenderMergeHelp" class="mr-widget-footer"><mr-widget-merge-help /></div>
    </div>
    <mr-widget-pipeline-container
      v-if="shouldRenderMergedPipeline"
      class="js-post-merge-pipeline mr-widget-workflow"
      :mr="mr"
      :is-post-merge="true"
    />
  </div>
  <loading v-else />
</template>
