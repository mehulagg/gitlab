import ceMutations from '~/vue_shared/security_reports/store/modules/sast/mutations';
import { findIssueIndex } from '../../utils';
import * as types from './mutation_types';

export default {
  ...ceMutations,

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
