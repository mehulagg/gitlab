<script>
import { mapActions, mapState, mapGetters } from 'vuex';
import IssueModal from 'ee/vue_shared/security_reports/components/modal.vue';
import Filters from './filters.vue';
import SecurityDashboardLayout from './security_dashboard_layout.vue';
import SecurityDashboardTable from './security_dashboard_table.vue';
import VulnerabilityChart from './vulnerability_chart.vue';
import FuzzingArtifactsDownload from './fuzzing_artifacts_download.vue';
import LoadingError from './loading_error.vue';

export default {
  components: {
    Filters,
    IssueModal,
    SecurityDashboardLayout,
    SecurityDashboardTable,
    VulnerabilityChart,
    FuzzingArtifactsDownload,
    LoadingError,
  },
  props: {
    vulnerabilitiesEndpoint: {
      type: String,
      required: true,
    },
    vulnerabilitiesHistoryEndpoint: {
      type: String,
      required: false,
      default: '',
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
    ...mapState('filters', ['filters']),
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
    shouldShowAside() {
      return this.shouldShowChart;
    },
    shouldShowChart() {
      return Boolean(this.vulnerabilitiesHistoryEndpoint);
    },
  },
  created() {
    this.setPipelineId(this.pipelineId);
    this.setVulnerabilitiesEndpoint(this.vulnerabilitiesEndpoint);
    this.setVulnerabilitiesHistoryEndpoint(this.vulnerabilitiesHistoryEndpoint);
    this.fetchVulnerabilities({ ...this.filters, page: this.pageInfo.page });
    this.fetchVulnerabilitiesHistory(this.filters);
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
      'fetchVulnerabilitiesHistory',
      'openDismissalCommentBox',
      'setPipelineId',
      'setVulnerabilitiesEndpoint',
      'setVulnerabilitiesHistoryEndpoint',
      'showDismissalDeleteButtons',
      'hideDismissalDeleteButtons',
      'undoDismiss',
      'downloadPatch',
    ]),
    ...mapActions('pipelineJobs', ['fetchPipelineJobs']),
    ...mapActions('filters', ['lockFilter', 'setHideDismissedToggleInitialState']),
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
          <filters>
            <template v-if="hasFuzzingArtifacts" #buttons>
              <fuzzing-artifacts-download :jobs="fuzzingJobsWithArtifact" :project-id="projectId">
                <template #label>
                  <strong>{{ s__('SecurityReports|Download Report') }}</strong>
                </template>
              </fuzzing-artifacts-download>
            </template>
          </filters>
        </template>

        <security-dashboard-table>
          <template #empty-state>
            <slot name="empty-state"></slot>
          </template>
        </security-dashboard-table>

        <template v-if="shouldShowAside" #aside>
          <vulnerability-chart v-if="shouldShowChart" class="mb-3" />
        </template>
      </security-dashboard-layout>

      <issue-modal
        :modal="modal"
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
