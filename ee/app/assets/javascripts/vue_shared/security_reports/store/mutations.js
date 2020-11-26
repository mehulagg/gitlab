import Vue from 'vue';
import { visitUrl } from '~/lib/utils/url_utility';
import { parseDiff } from '~/vue_shared/security_reports/store/utils';
import * as types from './mutation_types';
import { findIssueIndex } from './utils';

export default {
  [types.SET_HEAD_BLOB_PATH](state, path) {
    Vue.set(state.blobPath, 'head', path);
  },

  [types.SET_BASE_BLOB_PATH](state, path) {
    Vue.set(state.blobPath, 'base', path);
  },

  [types.SET_SOURCE_BRANCH](state, branch) {
    state.sourceBranch = branch;
  },

  [types.SET_CAN_READ_VULNERABILITY_FEEDBACK](state, value) {
    state.canReadVulnerabilityFeedback = value;
  },

  [types.SET_VULNERABILITY_FEEDBACK_PATH](state, path) {
    state.vulnerabilityFeedbackPath = path;
  },

  [types.SET_CREATE_VULNERABILITY_FEEDBACK_ISSUE_PATH](state, path) {
    state.createVulnerabilityFeedbackIssuePath = path;
  },

  [types.SET_CREATE_VULNERABILITY_FEEDBACK_MERGE_REQUEST_PATH](state, path) {
    state.createVulnerabilityFeedbackMergeRequestPath = path;
  },

  [types.SET_CREATE_VULNERABILITY_FEEDBACK_DISMISSAL_PATH](state, path) {
    state.createVulnerabilityFeedbackDismissalPath = path;
  },

  [types.SET_PIPELINE_ID](state, id) {
    state.pipelineId = id;
  },

  // CONTAINER SCANNING
  [types.SET_CONTAINER_SCANNING_DIFF_ENDPOINT](state, path) {
    Vue.set(state.containerScanning.paths, 'diffEndpoint', path);
  },

  [types.REQUEST_CONTAINER_SCANNING_DIFF](state) {
    Vue.set(state.containerScanning, 'isLoading', true);
  },

  [types.RECEIVE_CONTAINER_SCANNING_DIFF_SUCCESS](state, { diff, enrichData }) {
    const { added, fixed, existing } = parseDiff(diff, enrichData);
    const baseReportOutofDate = diff.base_report_out_of_date || false;
    const hasBaseReport = Boolean(diff.base_report_created_at);

    Vue.set(state.containerScanning, 'isLoading', false);
    Vue.set(state.containerScanning, 'newIssues', added);
    Vue.set(state.containerScanning, 'resolvedIssues', fixed);
    Vue.set(state.containerScanning, 'allIssues', existing);
    Vue.set(state.containerScanning, 'baseReportOutofDate', baseReportOutofDate);
    Vue.set(state.containerScanning, 'hasBaseReport', hasBaseReport);
  },

  [types.RECEIVE_CONTAINER_SCANNING_DIFF_ERROR](state) {
    Vue.set(state.containerScanning, 'isLoading', false);
    Vue.set(state.containerScanning, 'hasError', true);
  },

  // DAST

  [types.SET_DAST_DIFF_ENDPOINT](state, path) {
    Vue.set(state.dast.paths, 'diffEndpoint', path);
  },

  [types.REQUEST_DAST_DIFF](state) {
    Vue.set(state.dast, 'isLoading', true);
  },

  [types.RECEIVE_DAST_DIFF_SUCCESS](state, { diff, enrichData }) {
    const { added, fixed, existing } = parseDiff(diff, enrichData);
    const baseReportOutofDate = diff.base_report_out_of_date || false;
    const scans = diff.scans || [];
    const hasBaseReport = Boolean(diff.base_report_created_at);

    Vue.set(state.dast, 'isLoading', false);
    Vue.set(state.dast, 'newIssues', added);
    Vue.set(state.dast, 'resolvedIssues', fixed);
    Vue.set(state.dast, 'allIssues', existing);
    Vue.set(state.dast, 'baseReportOutofDate', baseReportOutofDate);
    Vue.set(state.dast, 'hasBaseReport', hasBaseReport);
    Vue.set(state.dast, 'scans', scans);
  },

  [types.RECEIVE_DAST_DIFF_ERROR](state) {
    Vue.set(state.dast, 'isLoading', false);
    Vue.set(state.dast, 'hasError', true);
  },

  // COVERAGE_FUZZING

  [types.SET_COVERAGE_FUZZING_DIFF_ENDPOINT](state, path) {
    Vue.set(state.coverageFuzzing.paths, 'diffEndpoint', path);
  },

  [types.REQUEST_COVERAGE_FUZZING_DIFF](state) {
    Vue.set(state.coverageFuzzing, 'isLoading', true);
  },

  [types.RECEIVE_COVERAGE_FUZZING_DIFF_SUCCESS](state, { diff, enrichData }) {
    const { added, fixed, existing } = parseDiff(diff, enrichData);
    const baseReportOutofDate = diff.base_report_out_of_date || false;
    const scans = diff.scans || [];
    const hasBaseReport = Boolean(diff.base_report_created_at);

    Vue.set(state.coverageFuzzing, 'isLoading', false);
    Vue.set(state.coverageFuzzing, 'newIssues', added);
    Vue.set(state.coverageFuzzing, 'resolvedIssues', fixed);
    Vue.set(state.coverageFuzzing, 'allIssues', existing);
    Vue.set(state.coverageFuzzing, 'baseReportOutofDate', baseReportOutofDate);
    Vue.set(state.coverageFuzzing, 'hasBaseReport', hasBaseReport);
    Vue.set(state.coverageFuzzing, 'scans', scans);
  },

  [types.RECEIVE_COVERAGE_FUZZING_DIFF_ERROR](state) {
    Vue.set(state.coverageFuzzing, 'isLoading', false);
    Vue.set(state.coverageFuzzing, 'hasError', true);
  },

  // DEPENDECY SCANNING

  [types.SET_DEPENDENCY_SCANNING_DIFF_ENDPOINT](state, path) {
    Vue.set(state.dependencyScanning.paths, 'diffEndpoint', path);
  },

  [types.REQUEST_DEPENDENCY_SCANNING_DIFF](state) {
    Vue.set(state.dependencyScanning, 'isLoading', true);
  },

  [types.RECEIVE_DEPENDENCY_SCANNING_DIFF_SUCCESS](state, { diff, enrichData }) {
    const { added, fixed, existing } = parseDiff(diff, enrichData);
    const baseReportOutofDate = diff.base_report_out_of_date || false;
    const hasBaseReport = Boolean(diff.base_report_created_at);

    Vue.set(state.dependencyScanning, 'isLoading', false);
    Vue.set(state.dependencyScanning, 'newIssues', added);
    Vue.set(state.dependencyScanning, 'resolvedIssues', fixed);
    Vue.set(state.dependencyScanning, 'allIssues', existing);
    Vue.set(state.dependencyScanning, 'baseReportOutofDate', baseReportOutofDate);
    Vue.set(state.dependencyScanning, 'hasBaseReport', hasBaseReport);
  },

  [types.RECEIVE_DEPENDENCY_SCANNING_DIFF_ERROR](state) {
    Vue.set(state.dependencyScanning, 'isLoading', false);
    Vue.set(state.dependencyScanning, 'hasError', true);
  },

  [types.SET_ISSUE_MODAL_DATA](state, payload) {
    const { issue, status } = payload;

    Vue.set(state.modal, 'title', issue.title);
    Vue.set(state.modal, 'vulnerability', issue);
    Vue.set(state.modal, 'isResolved', status === 'success');

    // clear previous state
    Vue.set(state.modal, 'error', null);
  },

  [types.REQUEST_DISMISS_VULNERABILITY](state) {
    state.isDismissingVulnerability = true;
    // reset error in case previous state was error
    Vue.set(state.modal, 'error', null);
  },

  [types.RECEIVE_DISMISS_VULNERABILITY_SUCCESS](state) {
    state.isDismissingVulnerability = false;
  },

  [types.RECEIVE_DISMISS_VULNERABILITY_ERROR](state, error) {
    Vue.set(state.modal, 'error', error);
    state.isDismissingVulnerability = false;
  },

  [types.REQUEST_ADD_DISMISSAL_COMMENT](state) {
    state.isDismissingVulnerability = true;
    Vue.set(state.modal, 'error', null);
  },

  [types.RECEIVE_ADD_DISMISSAL_COMMENT_SUCCESS](state, payload) {
    state.isDismissingVulnerability = false;
    Vue.set(state.modal.vulnerability, 'isDismissed', true);
    Vue.set(state.modal.vulnerability, 'dismissalFeedback', payload.data);
  },

  [types.RECEIVE_ADD_DISMISSAL_COMMENT_ERROR](state, error) {
    state.isDismissingVulnerability = false;
    Vue.set(state.modal, 'error', error);
  },
  [types.REQUEST_DELETE_DISMISSAL_COMMENT](state) {
    state.isDismissingVulnerability = true;
    Vue.set(state.modal, 'error', null);
  },
  [types.RECEIVE_DELETE_DISMISSAL_COMMENT_SUCCESS](state, payload) {
    state.isDismissingVulnerability = false;
    Vue.set(state.modal.vulnerability, 'isDismissed', true);
    Vue.set(state.modal.vulnerability, 'dismissalFeedback', payload.data);
  },
  [types.RECEIVE_DELETE_DISMISSAL_COMMENT_ERROR](state, error) {
    state.isDismissingVulnerability = false;
    Vue.set(state.modal, 'error', error);
  },
  [types.SHOW_DISMISSAL_DELETE_BUTTONS](state) {
    Vue.set(state.modal, 'isShowingDeleteButtons', true);
  },
  [types.HIDE_DISMISSAL_DELETE_BUTTONS](state) {
    Vue.set(state.modal, 'isShowingDeleteButtons', false);
  },
  [types.UPDATE_DEPENDENCY_SCANNING_ISSUE](state, issue) {
    // Find issue in the correct list and update it

    const newIssuesIndex = findIssueIndex(state.dependencyScanning.newIssues, issue);
    if (newIssuesIndex !== -1) {
      state.dependencyScanning.newIssues.splice(newIssuesIndex, 1, issue);
      return;
    }

    const resolvedIssuesIndex = findIssueIndex(state.dependencyScanning.resolvedIssues, issue);
    if (resolvedIssuesIndex !== -1) {
      state.dependencyScanning.resolvedIssues.splice(resolvedIssuesIndex, 1, issue);
      return;
    }

    const allIssuesIndex = findIssueIndex(state.dependencyScanning.allIssues, issue);
    if (allIssuesIndex !== -1) {
      state.dependencyScanning.allIssues.splice(allIssuesIndex, 1, issue);
    }
  },

  [types.UPDATE_CONTAINER_SCANNING_ISSUE](state, issue) {
    // Find issue in the correct list and update it

    const newIssuesIndex = findIssueIndex(state.containerScanning.newIssues, issue);
    if (newIssuesIndex !== -1) {
      state.containerScanning.newIssues.splice(newIssuesIndex, 1, issue);
      return;
    }

    const resolvedIssuesIndex = findIssueIndex(state.containerScanning.resolvedIssues, issue);
    if (resolvedIssuesIndex !== -1) {
      state.containerScanning.resolvedIssues.splice(resolvedIssuesIndex, 1, issue);
    }
  },

  [types.UPDATE_DAST_ISSUE](state, issue) {
    // Find issue in the correct list and update it

    const newIssuesIndex = findIssueIndex(state.dast.newIssues, issue);
    if (newIssuesIndex !== -1) {
      state.dast.newIssues.splice(newIssuesIndex, 1, issue);
      return;
    }

    const resolvedIssuesIndex = findIssueIndex(state.dast.resolvedIssues, issue);
    if (resolvedIssuesIndex !== -1) {
      state.dast.resolvedIssues.splice(resolvedIssuesIndex, 1, issue);
    }
  },

  [types.REQUEST_CREATE_ISSUE](state) {
    state.isCreatingIssue = true;
    // reset error in case previous state was error
    Vue.set(state.modal, 'error', null);
  },

  [types.RECEIVE_CREATE_ISSUE_SUCCESS](state) {
    state.isCreatingIssue = false;
  },

  [types.RECEIVE_CREATE_ISSUE_ERROR](state, error) {
    Vue.set(state.modal, 'error', error);
    state.isCreatingIssue = false;
  },

  [types.REQUEST_CREATE_MERGE_REQUEST](state) {
    state.isCreatingMergeRequest = true;
    Vue.set(state.modal, 'error', null);
  },
  [types.RECEIVE_CREATE_MERGE_REQUEST_SUCCESS](state, payload) {
    // We don't cancel the loading state here because we're navigating away from the page
    visitUrl(payload.merge_request_path);
  },
  [types.RECEIVE_CREATE_MERGE_REQUEST_ERROR](state, error) {
    state.isCreatingMergeRequest = false;
    Vue.set(state.modal, 'error', error);
  },
  [types.OPEN_DISMISSAL_COMMENT_BOX](state) {
    Vue.set(state.modal, 'isCommentingOnDismissal', true);
  },
  [types.CLOSE_DISMISSAL_COMMENT_BOX](state) {
    Vue.set(state.modal, 'isShowingDeleteButtons', false);
    Vue.set(state.modal, 'isCommentingOnDismissal', false);
  },
};
