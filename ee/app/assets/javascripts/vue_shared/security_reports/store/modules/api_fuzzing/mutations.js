import Vue from 'vue';
import { parseDiff } from '~/vue_shared/security_reports/store/utils';
import { findIssueIndex } from '../../utils';
import * as types from './mutation_types';

export default {
  [types.SET_DIFF_ENDPOINT](state, path) {
    state.paths.diffEndpoint = path;
  },

  [types.REQUEST_DIFF](state) {
    state.isLoading = true;
  },

  [types.RECEIVE_DIFF_SUCCESS](state, { diff, enrichData }) {
    const { added, fixed, existing } = parseDiff(diff, enrichData);
    const baseReportOutofDate = diff.base_report_out_of_date || false;
    const scans = diff.scans || [];
    const hasBaseReport = Boolean(diff.base_report_created_at);

    state.isLoading = false;
    state.newIssues = added;
    state.resolvedIssues = fixed;
    state.allIssues = existing;
    state.baseReportOutofDate = baseReportOutofDate;
    state.hasBaseReport = hasBaseReport;
    state.scans = scans;
  },

  [types.RECEIVE_DIFF_ERROR](state) {
    Vue.set(state, 'isLoading', false);
    Vue.set(state, 'hasError', true);
  },
  [types.UPDATE_VULNERABILITY](state, issue) {
    const newIssuesIndex = findIssueIndex(state.newIssues, issue);
    if (newIssuesIndex !== -1) {
      state.newIssues.splice(newIssuesIndex, 1, issue);
      return;
    }

    const resolvedIssuesIndex = findIssueIndex(state.resolvedIssues, issue);
    if (resolvedIssuesIndex !== -1) {
      state.resolvedIssues.splice(resolvedIssuesIndex, 1, issue);
      return;
    }

    const allIssuesIndex = findIssueIndex(state.allIssues, issue);
    if (allIssuesIndex !== -1) {
      state.allIssues.splice(allIssuesIndex, 1, issue);
    }
  },
};
