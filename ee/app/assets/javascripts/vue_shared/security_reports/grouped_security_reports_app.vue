<script>
import { mapActions, mapState, mapGetters } from 'vuex';
import { once } from 'lodash';
import { componentNames } from 'ee/reports/components/issue_body';
import { GlButton, GlSprintf, GlLink, GlModalDirective } from '@gitlab/ui';
import { trackMrSecurityReportDetails } from 'ee/vue_shared/security_reports/store/constants';
import FuzzingArtifactsDownload from 'ee/security_dashboard/components/fuzzing_artifacts_download.vue';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import ReportSection from '~/reports/components/report_section.vue';
import SummaryRow from '~/reports/components/summary_row.vue';
import Tracking from '~/tracking';
import GroupedIssuesList from '~/reports/components/grouped_issues_list.vue';
import IssueModal from './components/modal.vue';
import DastModal from './components/dast_modal.vue';
import securityReportsMixin from './mixins/security_report_mixin';
import createStore from './store';
import { mrStates } from '~/mr_popover/constants';
import { fetchPolicies } from '~/lib/graphql';
import securityReportSummaryQuery from './graphql/mr_security_report_summary.graphql';
import SecuritySummary from './components/security_summary.vue';

export default {
  store: createStore(),
  components: {
    GroupedIssuesList,
    ReportSection,
    SummaryRow,
    SecuritySummary,
    IssueModal,
    GlSprintf,
    GlLink,
    DastModal,
    GlButton,
    FuzzingArtifactsDownload,
  },
  directives: {
    'gl-modal': GlModalDirective,
  },
  mixins: [securityReportsMixin, glFeatureFlagsMixin()],
  apollo: {
    dastSummary: {
      query: securityReportSummaryQuery,
      fetchPolicy: fetchPolicies.NETWORK_ONLY,
      variables() {
        return {
          fullPath: this.projectFullPath,
          pipelineIid: this.pipelineIid,
        };
      },
      update(data) {
        const dast = data?.project?.pipeline?.securityReportSummary?.dast;
        return dast && Object.keys(dast).length ? dast : null;
      },
    },
  },
  props: {
    enabledReports: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    headBlobPath: {
      type: String,
      required: true,
    },
    baseBlobPath: {
      type: String,
      required: false,
      default: null,
    },
    sourceBranch: {
      type: String,
      required: false,
      default: null,
    },
    targetBranch: {
      type: String,
      required: false,
      default: null,
    },
    sastHelpPath: {
      type: String,
      required: false,
      default: '',
    },
    containerScanningHelpPath: {
      type: String,
      required: false,
      default: '',
    },
    dastHelpPath: {
      type: String,
      required: false,
      default: '',
    },
    coverageFuzzingHelpPath: {
      type: String,
      required: false,
      default: '',
    },
    dependencyScanningHelpPath: {
      type: String,
      required: false,
      default: '',
    },
    secretScanningHelpPath: {
      type: String,
      required: false,
      default: '',
    },
    canReadVulnerabilityFeedback: {
      type: Boolean,
      required: false,
      default: false,
    },
    vulnerabilityFeedbackPath: {
      type: String,
      required: false,
      default: '',
    },
    vulnerabilityFeedbackHelpPath: {
      type: String,
      required: false,
      default: '',
    },
    createVulnerabilityFeedbackIssuePath: {
      type: String,
      required: false,
      default: '',
    },
    createVulnerabilityFeedbackMergeRequestPath: {
      type: String,
      required: false,
      default: '',
    },
    createVulnerabilityFeedbackDismissalPath: {
      type: String,
      required: false,
      default: '',
    },
    pipelineId: {
      type: Number,
      required: false,
      default: null,
    },
    pipelineIid: {
      type: Number,
      required: false,
      default: null,
    },
    pipelinePath: {
      type: String,
      required: false,
      default: undefined,
    },
    divergedCommitsCount: {
      type: Number,
      required: false,
      default: 0,
    },
    mrState: {
      type: String,
      required: false,
      default: null,
    },
    targetBranchTreePath: {
      type: String,
      required: false,
      default: '',
    },
    newPipelinePath: {
      type: String,
      required: false,
      default: '',
    },
    projectId: {
      type: Number,
      required: false,
      default: null,
    },
    projectFullPath: {
      type: String,
      required: true,
    },
  },
  componentNames,
  computed: {
    ...mapState([
      'sast',
      'containerScanning',
      'dast',
      'coverageFuzzing',
      'dependencyScanning',
      'secretScanning',
      'summaryCounts',
      'modal',
      'isCreatingIssue',
      'isDismissingVulnerability',
      'isCreatingMergeRequest',
    ]),
    ...mapGetters([
      'groupedSummaryText',
      'summaryStatus',
      'groupedContainerScanningText',
      'groupedDastText',
      'groupedDependencyText',
      'groupedSecretScanningText',
      'groupedCoverageFuzzingText',
      'containerScanningStatusIcon',
      'dastStatusIcon',
      'dependencyScanningStatusIcon',
      'secretScanningStatusIcon',
      'coverageFuzzingStatusIcon',
      'isBaseSecurityReportOutOfDate',
      'canCreateIssue',
      'canCreateMergeRequest',
      'canDismissVulnerability',
    ]),
    ...mapGetters('sast', ['groupedSastText', 'sastStatusIcon']),
    ...mapGetters('pipelineJobs', ['hasFuzzingArtifacts', 'fuzzingJobsWithArtifact']),
    securityTab() {
      return `${this.pipelinePath}/security`;
    },
    hasContainerScanningReports() {
      return this.enabledReports.containerScanning;
    },
    hasDependencyScanningReports() {
      return this.enabledReports.dependencyScanning;
    },
    hasDastReports() {
      return this.enabledReports.dast;
    },
    hasCoverageFuzzingReports() {
      // TODO: Remove feature flag in https://gitlab.com/gitlab-org/gitlab/-/issues/257839
      return this.enabledReports.coverageFuzzing && this.glFeatures.coverageFuzzingMrWidget;
    },
    hasSastReports() {
      return this.enabledReports.sast;
    },
    hasSecretScanningReports() {
      return this.enabledReports.secretDetection;
    },
    isMRActive() {
      return this.mrState !== mrStates.merged && this.mrState !== mrStates.closed;
    },
    isMRBranchOutdated() {
      return this.divergedCommitsCount > 0;
    },
    hasDastScannedResources() {
      return this.dastSummary?.scannedResourcesCount > 0;
    },
    handleToggleEvent() {
      return once(() => {
        const { category, action } = trackMrSecurityReportDetails;
        Tracking.event(category, action);
      });
    },
    dastDownloadLink() {
      return this.dastSummary?.scannedResourcesCsvPath || '';
    },
    coverageFuzzingShowIssues() {
      return this.coverageFuzzing.newIssues || this.coverageFuzzing.resolvedIssues;
    },
  },

  created() {
    this.setHeadBlobPath(this.headBlobPath);
    this.setBaseBlobPath(this.baseBlobPath);
    this.setSourceBranch(this.sourceBranch);

    this.setCanReadVulnerabilityFeedback(this.canReadVulnerabilityFeedback);
    this.setVulnerabilityFeedbackPath(this.vulnerabilityFeedbackPath);
    this.setVulnerabilityFeedbackHelpPath(this.vulnerabilityFeedbackHelpPath);
    this.setCreateVulnerabilityFeedbackIssuePath(this.createVulnerabilityFeedbackIssuePath);
    this.setCreateVulnerabilityFeedbackMergeRequestPath(
      this.createVulnerabilityFeedbackMergeRequestPath,
    );
    this.setCreateVulnerabilityFeedbackDismissalPath(this.createVulnerabilityFeedbackDismissalPath);
    this.setProjectId(this.projectId);
    this.setPipelineId(this.pipelineId);
    this.setPipelineJobsId(this.pipelineId);

    const sastDiffEndpoint = gl?.mrWidgetData?.sast_comparison_path;

    if (sastDiffEndpoint && this.hasSastReports) {
      this.setSastDiffEndpoint(sastDiffEndpoint);
      this.fetchSastDiff();
    }

    const containerScanningDiffEndpoint = gl?.mrWidgetData?.container_scanning_comparison_path;

    if (containerScanningDiffEndpoint && this.hasContainerScanningReports) {
      this.setContainerScanningDiffEndpoint(containerScanningDiffEndpoint);
      this.fetchContainerScanningDiff();
    }

    const dastDiffEndpoint = gl?.mrWidgetData?.dast_comparison_path;

    if (dastDiffEndpoint && this.hasDastReports) {
      this.setDastDiffEndpoint(dastDiffEndpoint);
      this.fetchDastDiff();
    }

    const dependencyScanningDiffEndpoint = gl?.mrWidgetData?.dependency_scanning_comparison_path;

    if (dependencyScanningDiffEndpoint && this.hasDependencyScanningReports) {
      this.setDependencyScanningDiffEndpoint(dependencyScanningDiffEndpoint);
      this.fetchDependencyScanningDiff();
    }

    const secretScanningDiffEndpoint = gl?.mrWidgetData?.secret_scanning_comparison_path;
    if (secretScanningDiffEndpoint && this.hasSecretScanningReports) {
      this.setSecretScanningDiffEndpoint(secretScanningDiffEndpoint);
      this.fetchSecretScanningDiff();
    }

    const coverageFuzzingDiffEndpoint = gl?.mrWidgetData?.coverage_fuzzing_comparison_path;

    if (coverageFuzzingDiffEndpoint && this.hasCoverageFuzzingReports) {
      this.setCoverageFuzzingDiffEndpoint(coverageFuzzingDiffEndpoint);
      this.fetchCoverageFuzzingDiff();
      this.fetchPipelineJobs();
    }
  },
  methods: {
    ...mapActions([
      'setAppType',
      'setHeadBlobPath',
      'setBaseBlobPath',
      'setSourceBranch',
      'setCanReadVulnerabilityFeedback',
      'setVulnerabilityFeedbackPath',
      'setVulnerabilityFeedbackHelpPath',
      'setCreateVulnerabilityFeedbackIssuePath',
      'setCreateVulnerabilityFeedbackMergeRequestPath',
      'setCreateVulnerabilityFeedbackDismissalPath',
      'setPipelineId',
      'dismissVulnerability',
      'revertDismissVulnerability',
      'createNewIssue',
      'createMergeRequest',
      'openDismissalCommentBox',
      'closeDismissalCommentBox',
      'downloadPatch',
      'addDismissalComment',
      'deleteDismissalComment',
      'showDismissalDeleteButtons',
      'hideDismissalDeleteButtons',
      'fetchContainerScanningDiff',
      'setContainerScanningDiffEndpoint',
      'fetchDependencyScanningDiff',
      'setDependencyScanningDiffEndpoint',
      'fetchDastDiff',
      'setDastDiffEndpoint',
      'fetchSecretScanningDiff',
      'setSecretScanningDiffEndpoint',
      'fetchCoverageFuzzingDiff',
      'setCoverageFuzzingDiffEndpoint',
    ]),
    ...mapActions('sast', {
      setSastDiffEndpoint: 'setDiffEndpoint',
      fetchSastDiff: 'fetchDiff',
    }),
    ...mapActions('pipelineJobs', ['fetchPipelineJobs', 'setPipelineJobsPath', 'setProjectId']),
    ...mapActions('pipelineJobs', {
      setPipelineJobsId: 'setPipelineId',
    }),
  },
  summarySlots: ['success', 'error', 'loading'],
};
</script>
<template>
  <report-section
    :status="summaryStatus"
    :has-issues="true"
    :should-emit-toggle-event="true"
    class="mr-widget-border-top grouped-security-reports mr-report"
    data-qa-selector="vulnerability_report_grouped"
    @toggleEvent="handleToggleEvent"
  >
    <template v-for="slot in $options.summarySlots" #[slot]>
      <security-summary :key="slot" :message="groupedSummaryText" />
    </template>

    <template v-if="pipelinePath" #actionButtons>
      <gl-button
        :href="securityTab"
        target="_blank"
        icon="external-link"
        class="gl-mr-3 report-btn"
      >
        {{ s__('ciReport|View full report') }}
      </gl-button>
    </template>

    <template v-if="isMRActive && isBaseSecurityReportOutOfDate" #subHeading>
      <div class="text-secondary-700 text-1">
        <gl-sprintf
          v-if="isMRBranchOutdated"
          :message="
            __(
              'Security report is out of date. Please update your branch with the latest changes from the target branch (%{targetBranchName})',
            )
          "
        >
          <template #targetBranchName>
            <gl-link class="text-1" :href="targetBranchTreePath">{{ targetBranch }}</gl-link>
          </template>
        </gl-sprintf>

        <gl-sprintf
          v-else
          :message="
            __(
              'Security report is out of date. Run %{newPipelineLinkStart}a new pipeline%{newPipelineLinkEnd} for the target branch (%{targetBranchName})',
            )
          "
        >
          <template #newPipelineLink="{ content }">
            <gl-link class="text-1" :href="`${newPipelinePath}?ref=${targetBranch}`">{{
              content
            }}</gl-link>
          </template>
          <template #targetBranchName>
            <gl-link class="text-1" :href="targetBranchTreePath">{{ targetBranch }}</gl-link>
          </template>
        </gl-sprintf>
      </div>
    </template>

    <template #body>
      <div class="mr-widget-grouped-section report-block">
        <template v-if="hasSastReports">
          <summary-row
            :status-icon="sastStatusIcon"
            :popover-options="sastPopover"
            class="js-sast-widget"
            data-qa-selector="sast_scan_report"
          >
            <template #summary>
              <security-summary :message="groupedSastText" />
            </template>
          </summary-row>

          <grouped-issues-list
            v-if="sast.newIssues.length || sast.resolvedIssues.length"
            :unresolved-issues="sast.newIssues"
            :resolved-issues="sast.resolvedIssues"
            :component="$options.componentNames.SecurityIssueBody"
            class="report-block-group-list"
            data-testid="sast-issues-list"
          />
        </template>

        <template v-if="hasDependencyScanningReports">
          <summary-row
            :status-icon="dependencyScanningStatusIcon"
            :popover-options="dependencyScanningPopover"
            class="js-dependency-scanning-widget"
            data-qa-selector="dependency_scan_report"
          >
            <template #summary>
              <security-summary :message="groupedDependencyText" />
            </template>
          </summary-row>

          <grouped-issues-list
            v-if="dependencyScanning.newIssues.length || dependencyScanning.resolvedIssues.length"
            :unresolved-issues="dependencyScanning.newIssues"
            :resolved-issues="dependencyScanning.resolvedIssues"
            :component="$options.componentNames.SecurityIssueBody"
            class="report-block-group-list"
            data-testid="dependency-scanning-issues-list"
          />
        </template>

        <template v-if="hasContainerScanningReports">
          <summary-row
            :status-icon="containerScanningStatusIcon"
            :popover-options="containerScanningPopover"
            class="js-container-scanning"
            data-qa-selector="container_scan_report"
          >
            <template #summary>
              <security-summary :message="groupedContainerScanningText" />
            </template>
          </summary-row>

          <grouped-issues-list
            v-if="containerScanning.newIssues.length || containerScanning.resolvedIssues.length"
            :unresolved-issues="containerScanning.newIssues"
            :resolved-issues="containerScanning.resolvedIssues"
            :component="$options.componentNames.SecurityIssueBody"
            class="report-block-group-list"
            data-testid="container-scanning-issues-list"
          />
        </template>

        <template v-if="hasDastReports">
          <summary-row
            :status-icon="dastStatusIcon"
            :popover-options="dastPopover"
            class="js-dast-widget"
            data-qa-selector="dast_scan_report"
          >
            <template #summary>
              <security-summary :message="groupedDastText" />
            </template>

            <template v-if="hasDastScannedResources">
              <div class="text-nowrap">
                {{ n__('%d URL scanned', '%d URLs scanned', dastSummary.scannedResourcesCount) }}
              </div>
              <gl-link v-gl-modal.dastUrl class="ml-2" data-qa-selector="dast-ci-job-link">
                {{ __('View details') }}
              </gl-link>
              <dast-modal
                :scanned-urls="dastSummary.scannedResources.nodes"
                :scanned-resources-count="dastSummary.scannedResourcesCount"
                :download-link="dastDownloadLink"
              />
            </template>
          </summary-row>
          <grouped-issues-list
            v-if="dast.newIssues.length || dast.resolvedIssues.length"
            :unresolved-issues="dast.newIssues"
            :resolved-issues="dast.resolvedIssues"
            :component="$options.componentNames.SecurityIssueBody"
            class="report-block-group-list"
            data-testid="dast-issues-list"
          />
        </template>

        <template v-if="hasSecretScanningReports">
          <summary-row
            :status-icon="secretScanningStatusIcon"
            :popover-options="secretScanningPopover"
            class="js-secret-scanning"
            data-qa-selector="secret_scan_report"
          >
            <template #summary>
              <security-summary :message="groupedSecretScanningText" />
            </template>
          </summary-row>

          <grouped-issues-list
            v-if="secretScanning.newIssues.length || secretScanning.resolvedIssues.length"
            :unresolved-issues="secretScanning.newIssues"
            :resolved-issues="secretScanning.resolvedIssues"
            :component="$options.componentNames.SecurityIssueBody"
            class="report-block-group-list"
            data-testid="secret-scanning-issues-list"
          />
        </template>

        <template v-if="hasCoverageFuzzingReports">
          <summary-row
            :status-icon="coverageFuzzingStatusIcon"
            :popover-options="coverageFuzzingPopover"
            class="js-coverage-fuzzing-widget"
            data-qa-selector="coverage_fuzzing_report"
          >
            <template #summary>
              <security-summary :message="groupedCoverageFuzzingText" />
            </template>
            <fuzzing-artifacts-download
              v-if="hasFuzzingArtifacts"
              :jobs="fuzzingJobsWithArtifact"
              :project-id="projectId"
            />
          </summary-row>

          <grouped-issues-list
            v-if="coverageFuzzingShowIssues"
            :unresolved-issues="coverageFuzzing.newIssues"
            :resolved-issues="coverageFuzzing.resolvedIssues"
            :component="$options.componentNames.SecurityIssueBody"
            class="report-block-group-list"
            data-testid="coverage-fuzzing-issues-list"
          />
        </template>

        <issue-modal
          :modal="modal"
          :vulnerability-feedback-help-path="vulnerabilityFeedbackHelpPath"
          :can-create-issue="canCreateIssue"
          :can-create-merge-request="canCreateMergeRequest"
          :can-dismiss-vulnerability="canDismissVulnerability"
          :is-creating-issue="isCreatingIssue"
          :is-dismissing-vulnerability="isDismissingVulnerability"
          :is-creating-merge-request="isCreatingMergeRequest"
          @closeDismissalCommentBox="closeDismissalCommentBox()"
          @createMergeRequest="createMergeRequest"
          @createNewIssue="createNewIssue"
          @dismissVulnerability="dismissVulnerability"
          @openDismissalCommentBox="openDismissalCommentBox()"
          @editVulnerabilityDismissalComment="openDismissalCommentBox()"
          @revertDismissVulnerability="revertDismissVulnerability"
          @downloadPatch="downloadPatch"
          @addDismissalComment="addDismissalComment({ comment: $event })"
          @deleteDismissalComment="deleteDismissalComment"
          @showDismissalDeleteButtons="showDismissalDeleteButtons"
          @hideDismissalDeleteButtons="hideDismissalDeleteButtons"
        />
      </div>
    </template>
  </report-section>
</template>
