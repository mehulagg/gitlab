<script>
import { GlSafeHtmlDirective } from '@gitlab/ui';
import GroupedMetricsReportsApp from 'ee/vue_shared/metrics_reports/grouped_metrics_reports_app.vue';
import reportsMixin from 'ee/vue_shared/security_reports/mixins/reports_mixin';
import { componentNames } from 'ee/reports/components/issue_body';
import MrWidgetLicenses from 'ee/vue_shared/license_compliance/mr_widget_license_report.vue';
import ReportSection from '~/reports/components/report_section.vue';
import { s__, __, sprintf } from '~/locale';
import CEWidgetOptions from '~/vue_merge_request_widget/mr_widget_options.vue';
import BlockingMergeRequestsReport from './components/blocking_merge_requests/blocking_merge_requests_report.vue';
import MrWidgetGeoSecondaryNode from './components/states/mr_widget_secondary_geo_node.vue';
import MrWidgetPolicyViolation from './components/states/mr_widget_policy_violation.vue';

export default {
  components: {
    MrWidgetLicenses,
    MrWidgetGeoSecondaryNode,
    MrWidgetPolicyViolation,
    BlockingMergeRequestsReport,
    GroupedSecurityReportsApp: () =>
      import('ee/vue_shared/security_reports/grouped_security_reports_app.vue'),
    GroupedMetricsReportsApp,
    ReportSection,
  },
  directives: {
    SafeHtml: GlSafeHtmlDirective,
  },
  extends: CEWidgetOptions,
  mixins: [reportsMixin],
  componentNames,
  data() {
    return {
      isLoadingBrowserPerformance: false,
      isLoadingLoadPerformance: false,
      loadingBrowserPerformanceFailed: false,
      loadingLoadPerformanceFailed: false,
      loadingLicenseReportFailed: false,
    };
  },
  computed: {
    shouldRenderLicenseReport() {
      return this.mr.enabledReports?.licenseScanning;
    },
    hasBrowserPerformanceMetrics() {
      return (
        this.mr.browserPerformanceMetrics?.degraded?.length > 0 ||
        this.mr.browserPerformanceMetrics?.improved?.length > 0 ||
        this.mr.browserPerformanceMetrics?.same?.length > 0
      );
    },
    hasBrowserPerformancePaths() {
      const browserPerformance = this.mr?.browserPerformance || {};

      return Boolean(browserPerformance?.head_path && browserPerformance?.base_path);
    },
    degradedBrowserPerformanceTotalScore() {
      return this.mr?.browserPerformanceMetrics?.degraded.find(
        (metric) => metric.name === __('Total Score'),
      );
    },
    hasBrowserPerformanceDegradation() {
      const threshold = this.mr?.browserPerformance?.degradation_threshold || 0;

      if (!threshold) {
        return true;
      }

      const totalScoreDelta = this.degradedBrowserPerformanceTotalScore?.delta || 0;

      return threshold + totalScoreDelta <= 0;
    },
    shouldRenderBrowserPerformance() {
      return this.hasBrowserPerformancePaths && this.hasBrowserPerformanceDegradation;
    },
    hasLoadPerformanceMetrics() {
      return (
        this.mr.loadPerformanceMetrics?.degraded?.length > 0 ||
        this.mr.loadPerformanceMetrics?.improved?.length > 0 ||
        this.mr.loadPerformanceMetrics?.same?.length > 0
      );
    },
    hasLoadPerformancePaths() {
      const loadPerformance = this.mr?.loadPerformance || {};

      return Boolean(loadPerformance.head_path && loadPerformance.base_path);
    },
    shouldRenderBaseSecurityReport() {
      return !this.mr.canReadVulnerabilities && this.shouldRenderSecurityReport;
    },
    shouldRenderExtendedSecurityReport() {
      const { enabledReports } = this.mr;
      return (
        this.mr.canReadVulnerabilities &&
        enabledReports &&
        this.$options.securityReportTypes.some((reportType) => enabledReports[reportType])
      );
    },

    browserPerformanceText() {
      const { improved, degraded, same } = this.mr.browserPerformanceMetrics;
      const text = [];
      const reportNumbers = [];

      if (improved.length || degraded.length || same.length) {
        text.push(s__('ciReport|Browser performance test metrics: '));

        if (degraded.length > 0)
          reportNumbers.push(
            sprintf(s__('ciReport|%{degradedNum} degraded'), { degradedNum: degraded.length }),
          );
        if (same.length > 0)
          reportNumbers.push(sprintf(s__('ciReport|%{sameNum} same'), { sameNum: same.length }));
        if (improved.length > 0)
          reportNumbers.push(
            sprintf(s__('ciReport|%{improvedNum} improved'), { improvedNum: improved.length }),
          );
      } else {
        text.push(s__('ciReport|Browser performance test metrics: No changes'));
      }

      return [...text, ...reportNumbers.join(', ')].join('');
    },

    loadPerformanceText() {
      const { improved, degraded, same } = this.mr.loadPerformanceMetrics;
      const text = [];
      const reportNumbers = [];

      if (improved.length || degraded.length || same.length) {
        text.push(s__('ciReport|Load performance test metrics: '));

        if (degraded.length > 0)
          reportNumbers.push(
            sprintf(s__('ciReport|%{degradedNum} degraded'), { degradedNum: degraded.length }),
          );
        if (same.length > 0)
          reportNumbers.push(sprintf(s__('ciReport|%{sameNum} same'), { sameNum: same.length }));
        if (improved.length > 0)
          reportNumbers.push(
            sprintf(s__('ciReport|%{improvedNum} improved'), { improvedNum: improved.length }),
          );
      } else {
        text.push(s__('ciReport|Load performance test metrics: No changes'));
      }

      return [...text, ...reportNumbers.join(', ')].join('');
    },

    browserPerformanceStatus() {
      return this.checkReportStatus(
        this.isLoadingBrowserPerformance,
        this.loadingBrowserPerformanceFailed,
      );
    },

    loadPerformanceStatus() {
      return this.checkReportStatus(
        this.isLoadingLoadPerformance,
        this.loadingLoadPerformanceFailed,
      );
    },
    licensesApiPath() {
      return gl?.mrWidgetData?.license_scanning_comparison_path || null;
    },
  },
  watch: {
    hasBrowserPerformancePaths(newVal) {
      if (newVal) {
        this.fetchBrowserPerformance();
      }
    },
    hasLoadPerformancePaths(newVal) {
      if (newVal) {
        this.fetchLoadPerformance();
      }
    },
  },
  methods: {
    getServiceEndpoints(store) {
      const base = CEWidgetOptions.methods.getServiceEndpoints(store);

      return {
        ...base,
        apiApprovalSettingsPath: store.apiApprovalSettingsPath,
      };
    },

    fetchBrowserPerformance() {
      const { head_path, base_path } = this.mr.browserPerformance;

      this.isLoadingBrowserPerformance = true;

      Promise.all([this.service.fetchReport(head_path), this.service.fetchReport(base_path)])
        .then((values) => {
          this.mr.compareBrowserPerformanceMetrics(values[0], values[1]);
        })
        .catch(() => {
          this.loadingBrowserPerformanceFailed = true;
        })
        .finally(() => {
          this.isLoadingBrowserPerformance = false;
        });
    },

    fetchLoadPerformance() {
      const { head_path, base_path } = this.mr.loadPerformance;

      this.isLoadingLoadPerformance = true;

      Promise.all([this.service.fetchReport(head_path), this.service.fetchReport(base_path)])
        .then((values) => {
          this.mr.compareLoadPerformanceMetrics(values[0], values[1]);
        })
        .catch(() => {
          this.loadingLoadPerformanceFailed = true;
        })
        .finally(() => {
          this.isLoadingLoadPerformance = false;
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
  // TODO: Use the snake_case report types rather than the camelCased versions
  // of them. See https://gitlab.com/gitlab-org/gitlab/-/issues/282430
  securityReportTypes: [
    'dast',
    'sast',
    'dependencyScanning',
    'containerScanning',
    'coverageFuzzing',
    'apiFuzzing',
    'secretDetection',
  ],
};
</script>
<template>
  <div v-if="isLoaded" class="mr-state-widget gl-mt-3">
    <mr-widget-header :mr="mr" />
    <mr-widget-suggest-pipeline
      v-if="shouldSuggestPipelines"
      class="mr-widget-workflow"
      :pipeline-path="mr.mergeRequestAddCiConfigPath"
      :pipeline-svg-path="mr.pipelinesEmptySvgPath"
      :human-access="formattedHumanAccess"
      :user-callouts-path="mr.userCalloutsPath"
      :user-callout-feature-id="mr.suggestPipelineFeatureId"
      @dismiss="dismissSuggestPipelines"
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
      <grouped-codequality-reports-app
        v-if="shouldRenderCodeQuality"
        :base-path="mr.codeclimate.base_path"
        :head-path="mr.codeclimate.head_path"
        :head-blob-path="mr.headBlobPath"
        :base-blob-path="mr.baseBlobPath"
        :codequality-help-path="mr.codequalityHelpPath"
      />
      <report-section
        v-if="shouldRenderBrowserPerformance"
        :status="browserPerformanceStatus"
        :loading-text="translateText('browser-performance').loading"
        :error-text="translateText('browser-performance').error"
        :success-text="browserPerformanceText"
        :unresolved-issues="mr.browserPerformanceMetrics.degraded"
        :resolved-issues="mr.browserPerformanceMetrics.improved"
        :neutral-issues="mr.browserPerformanceMetrics.same"
        :has-issues="hasBrowserPerformanceMetrics"
        :component="$options.componentNames.PerformanceIssueBody"
        class="js-browser-performance-widget mr-widget-border-top mr-report"
      />
      <report-section
        v-if="hasLoadPerformancePaths"
        :status="loadPerformanceStatus"
        :loading-text="translateText('load-performance').loading"
        :error-text="translateText('load-performance').error"
        :success-text="loadPerformanceText"
        :unresolved-issues="mr.loadPerformanceMetrics.degraded"
        :resolved-issues="mr.loadPerformanceMetrics.improved"
        :neutral-issues="mr.loadPerformanceMetrics.same"
        :has-issues="hasLoadPerformanceMetrics"
        :component="$options.componentNames.PerformanceIssueBody"
        class="js-load-performance-widget mr-widget-border-top mr-report"
      />
      <grouped-metrics-reports-app
        v-if="mr.metricsReportsPath"
        :endpoint="mr.metricsReportsPath"
        class="js-metrics-reports-container"
      />

      <security-reports-app
        v-if="shouldRenderBaseSecurityReport"
        :pipeline-id="mr.pipeline.id"
        :project-id="mr.sourceProjectId"
        :security-reports-docs-path="mr.securityReportsDocsPath"
        :sast-comparison-path="mr.sastComparisonPath"
        :secret-scanning-comparison-path="mr.secretScanningComparisonPath"
        :target-project-full-path="mr.targetProjectFullPath"
        :mr-iid="mr.iid"
        :discover-project-security-path="mr.discoverProjectSecurityPath"
      />
      <grouped-security-reports-app
        v-else-if="shouldRenderExtendedSecurityReport"
        :head-blob-path="mr.headBlobPath"
        :source-branch="mr.sourceBranch"
        :target-branch="mr.targetBranch"
        :base-blob-path="mr.baseBlobPath"
        :enabled-reports="mr.enabledReports"
        :sast-help-path="mr.sastHelp"
        :dast-help-path="mr.dastHelp"
        :api-fuzzing-help-path="mr.apiFuzzingHelp"
        :coverage-fuzzing-help-path="mr.coverageFuzzingHelp"
        :container-scanning-help-path="mr.containerScanningHelp"
        :dependency-scanning-help-path="mr.dependencyScanningHelp"
        :secret-scanning-help-path="mr.secretScanningHelp"
        :can-read-vulnerability-feedback="mr.canReadVulnerabilityFeedback"
        :vulnerability-feedback-path="mr.vulnerabilityFeedbackPath"
        :create-vulnerability-feedback-issue-path="mr.createVulnerabilityFeedbackIssuePath"
        :create-vulnerability-feedback-merge-request-path="
          mr.createVulnerabilityFeedbackMergeRequestPath
        "
        :create-vulnerability-feedback-dismissal-path="mr.createVulnerabilityFeedbackDismissalPath"
        :pipeline-path="mr.pipeline.path"
        :pipeline-id="mr.securityReportsPipelineId"
        :pipeline-iid="mr.securityReportsPipelineIid"
        :project-id="mr.targetProjectId"
        :project-full-path="mr.sourceProjectFullPath"
        :diverged-commits-count="mr.divergedCommitsCount"
        :mr-state="mr.state"
        :target-branch-tree-path="mr.targetBranchTreePath"
        :new-pipeline-path="mr.newPipelinePath"
        :container-scanning-comparison-path="mr.containerScanningComparisonPath"
        :api-fuzzing-comparison-path="mr.apiFuzzingComparisonPath"
        :coverage-fuzzing-comparison-path="mr.coverageFuzzingComparisonPath"
        :dast-comparison-path="mr.dastComparisonPath"
        :dependency-scanning-comparison-path="mr.dependencyScanningComparisonPath"
        :sast-comparison-path="mr.sastComparisonPath"
        :secret-scanning-comparison-path="mr.secretScanningComparisonPath"
        :target-project-full-path="mr.targetProjectFullPath"
        :mr-iid="mr.iid"
        class="js-security-widget"
      />
      <mr-widget-licenses
        v-if="shouldRenderLicenseReport"
        :api-url="mr.licenseScanning.managed_licenses_path"
        :approvals-api-path="mr.apiApprovalsPath"
        :licenses-api-path="licensesApiPath"
        :pipeline-path="mr.pipeline.path"
        :can-manage-licenses="mr.licenseScanning.can_manage_licenses"
        :full-report-path="mr.licenseScanning.full_report_path"
        :license-management-settings-path="mr.licenseScanning.settings_path"
        :security-approvals-help-page-path="mr.securityApprovalsHelpPagePath"
        report-section-class="mr-widget-border-top"
      />

      <grouped-test-reports-app
        v-if="mr.testResultsPath"
        class="js-reports-container"
        :endpoint="mr.testResultsPath"
        :pipeline-path="mr.pipeline.path"
      />

      <terraform-plan v-if="mr.terraformReportsPath" :endpoint="mr.terraformReportsPath" />

      <grouped-accessibility-reports-app
        v-if="shouldShowAccessibilityReport"
        :endpoint="mr.accessibilityReportPath"
      />

      <div class="mr-widget-section">
        <component :is="componentName" :mr="mr" :service="service" />
        <div class="mr-widget-info">
          <section v-if="mr.allowCollaboration" class="mr-info-list gl-ml-7">
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
                'mrWidget|Fork project merge requests do not create merge request pipelines that validate a post merge result unless invoked by a project member.',
              )
            }}
          </mr-widget-alert-message>

          <mr-widget-alert-message v-if="mr.mergeError" type="danger">
            <span v-safe-html="mergeError"></span>
          </mr-widget-alert-message>

          <source-branch-removal-status v-if="shouldRenderSourceBranchRemovalStatus" />
        </div>
      </div>
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
