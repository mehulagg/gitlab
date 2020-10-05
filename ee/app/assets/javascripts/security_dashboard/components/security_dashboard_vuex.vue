<script>
import { isUndefined } from 'lodash';
import { mapActions, mapState, mapGetters } from 'vuex';
import IssueModal from 'ee/vue_shared/security_reports/components/modal.vue';
import Filters from './filters.vue';
import SecurityDashboardLayout from './security_dashboard_layout.vue';
import SecurityDashboardTable from './security_dashboard_table.vue';
import VulnerabilityChart from './vulnerability_chart.vue';
import VulnerabilityCountList from './vulnerability_count_list_vuex.vue';
import VulnerabilitySeverity from './vulnerability_severity.vue';
import FuzzingArtifactsDownload from './fuzzing_artifacts_download.vue';
import LoadingError from './loading_error.vue';

export default {
  components: {
    Filters,
    IssueModal,
    SecurityDashboardLayout,
    SecurityDashboardTable,
    VulnerabilityChart,
    VulnerabilityCountList,
    VulnerabilitySeverity,
    FuzzingArtifactsDownload,
    LoadingError,
  },
  props: {
    vulnerabilitiesEndpoint: {
      type: String,
      required: true,
    },
    vulnerabilitiesCountEndpoint: {
      type: String,
      required: false,
      default: '',
    },
    vulnerabilitiesHistoryEndpoint: {
      type: String,
      required: false,
      default: '',
    },
    vulnerabilityFeedbackHelpPath: {
      type: String,
      required: true,
    },
    vulnerableProjectsEndpoint: {
      type: String,
      required: false,
      default: '',
    },
    lockToProject: {
      type: Object,
      required: false,
      default: null,
      validator: project => !isUndefined(project.id),
    },
    pipelineId: {
      type: Number,
      required: false,
      default: null,
    },
    loadingErrorIllustrations: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  computed: {
    ...mapState('vulnerabilities', [
      'modal',
      'pageInfo',
      'loadingVulnerabilitiesErrorCode',
      'isCreatingIssue',
      'isDismissingVulnerability',
      'isCreatingMergeRequest',
    ]),
    ...mapState('pipelineJobs', ['projectId']),
    ...mapGetters('filters', ['activeFilters']),
    ...mapGetters('vulnerabilities', ['loadingVulnerabilitiesFailedWithRecognizedErrorCode']),
    ...mapGetters('pipelineJobs', ['hasFuzzingArtifacts', 'fuzzingJobsWithArtifact']),
    canCreateIssue() {
      const path = this.vulnerability.create_vulnerability_feedback_issue_path;
      return Boolean(path);
    },
    canCreateMergeRequest() {
      const path = this.vulnerability.create_vulnerability_feedback_merge_request_path;
      return Boolean(path);
    },
    canDismissVulnerability() {
      const path = this.vulnerability.create_vulnerability_feedback_dismissal_path;
      return Boolean(path);
    },
    vulnerability() {
      return this.modal.vulnerability;
    },
    isLockedToProject() {
      return this.lockToProject !== null;
    },
    shouldShowAside() {
      return this.shouldShowChart || this.shouldShowVulnerabilitySeverities;
    },
    shouldShowChart() {
      return Boolean(this.vulnerabilitiesHistoryEndpoint);
    },
    shouldShowVulnerabilitySeverities() {
      return Boolean(this.vulnerableProjectsEndpoint);
    },
    shouldShowCountList() {
      return this.isLockedToProject && Boolean(this.vulnerabilitiesCountEndpoint);
    },
  },
  watch: {
    'pageInfo.total': 'emitVulnerabilitiesCountChanged',
  },
  created() {
    if (this.isLockedToProject) {
      this.lockFilter({
        filterId: 'project_id',
        optionId: this.lockToProject.id,
      });
    }
    this.setPipelineId(this.pipelineId);
    this.setHideDismissedToggleInitialState();
    this.setVulnerabilitiesEndpoint(this.vulnerabilitiesEndpoint);
    this.setVulnerabilitiesCountEndpoint(this.vulnerabilitiesCountEndpoint);
    this.setVulnerabilitiesHistoryEndpoint(this.vulnerabilitiesHistoryEndpoint);
    this.fetchVulnerabilities({ ...this.activeFilters, page: this.pageInfo.page });
    this.fetchVulnerabilitiesCount(this.activeFilters);
    this.fetchVulnerabilitiesHistory(this.activeFilters);
    this.fetchPipelineJobs();
  },
  methods: {
    ...mapActions('vulnerabilities', [
      'addDismissalComment',
      'deleteDismissalComment',
      'closeDismissalCommentBox',
      'createIssue',
      'createMergeRequest',
      'dismissVulnerability',
      'fetchVulnerabilities',
      'fetchVulnerabilitiesCount',
      'fetchVulnerabilitiesHistory',
      'openDismissalCommentBox',
      'setPipelineId',
      'setVulnerabilitiesCountEndpoint',
      'setVulnerabilitiesEndpoint',
      'setVulnerabilitiesHistoryEndpoint',
      'showDismissalDeleteButtons',
      'hideDismissalDeleteButtons',
      'undoDismiss',
      'downloadPatch',
    ]),
    ...mapActions('pipelineJobs', ['fetchPipelineJobs']),
    ...mapActions('filters', ['lockFilter', 'setHideDismissedToggleInitialState']),
    emitVulnerabilitiesCountChanged(count) {
      this.$emit('vulnerabilitiesCountChanged', count);
    },
  },
};
</script>

<template>
  <section>
    <loading-error
      v-if="loadingVulnerabilitiesFailedWithRecognizedErrorCode"
      :error-code="loadingVulnerabilitiesErrorCode"
      :illustrations="loadingErrorIllustrations"
    />
    <template v-else>
      <security-dashboard-layout>
        <template #header>
          <vulnerability-count-list v-if="shouldShowCountList" />
          <filters>
            <template v-if="hasFuzzingArtifacts" #buttons>
              <fuzzing-artifacts-download :jobs="fuzzingJobsWithArtifact" :project-id="projectId" />
            </template>
          </filters>
        </template>

        <security-dashboard-table>
          <template #emptyState>
            <slot name="emptyState"></slot>
          </template>
        </security-dashboard-table>

        <template v-if="shouldShowAside" #aside>
          <vulnerability-chart v-if="shouldShowChart" class="mb-3" />
          <vulnerability-severity
            v-if="shouldShowVulnerabilitySeverities"
            :endpoint="vulnerableProjectsEndpoint"
          />
        </template>
      </security-dashboard-layout>

      <issue-modal
        :modal="modal"
        :vulnerability-feedback-help-path="vulnerabilityFeedbackHelpPath"
        :can-create-issue="canCreateIssue"
        :can-create-merge-request="canCreateMergeRequest"
        :can-dismiss-vulnerability="canDismissVulnerability"
        :is-creating-issue="isCreatingIssue"
        :is-dismissing-vulnerability="isDismissingVulnerability"
        :is-creating-merge-request="isCreatingMergeRequest"
        @addDismissalComment="addDismissalComment({ vulnerability, comment: $event })"
        @editVulnerabilityDismissalComment="openDismissalCommentBox"
        @showDismissalDeleteButtons="showDismissalDeleteButtons"
        @hideDismissalDeleteButtons="hideDismissalDeleteButtons"
        @deleteDismissalComment="deleteDismissalComment({ vulnerability })"
        @closeDismissalCommentBox="closeDismissalCommentBox"
        @createMergeRequest="createMergeRequest({ vulnerability })"
        @createNewIssue="createIssue({ vulnerability })"
        @dismissVulnerability="dismissVulnerability({ vulnerability, comment: $event })"
        @openDismissalCommentBox="openDismissalCommentBox"
        @revertDismissVulnerability="undoDismiss({ vulnerability })"
        @downloadPatch="downloadPatch({ vulnerability })"
      />
    </template>
  </section>
</template>
