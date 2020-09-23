import * as types from './mutation_types';

export default {
  [types.SET_INITIAL_DATA](
    state,
    { variant, groupId, issueId, selectedEpic, selectedEpicIssueId },
  ) {
    state.variant = variant;
    state.groupId = groupId;
    state.issueId = issueId;
    state.selectedEpic = selectedEpic;
    state.selectedEpicIssueId = selectedEpicIssueId;
  },

  [types.SET_ISSUE_ID](state, issueId) {
    state.issueId = issueId;
  },

  [types.SET_SEARCH_QUERY](state, searchQuery) {
    state.searchQuery = searchQuery;
  },

  [types.SET_SELECTED_EPIC](state, selectedEpic) {
    state.selectedEpic = selectedEpic;
  },

  [types.SET_SELECTED_EPIC_ISSUE_ID](state, selectedEpicIssueId) {
    state.selectedEpicIssueId = selectedEpicIssueId;
  },

  [types.REQUEST_EPICS](state) {
    state.epicsFetchInProgress = true;
  },
  [types.RECEIVE_EPICS_SUCCESS](state, { epics }) {
    state.epicsFetchInProgress = false;
    state.epics = epics;
  },
  [types.RECEIVE_EPICS_FAILURE](state) {
    state.epicsFetchInProgress = false;
  },

  [types.REQUEST_ISSUE_UPDATE](state) {
    state.epicSelectInProgress = true;
  },
  [types.RECEIVE_ISSUE_UPDATE_SUCCESS](state, { selectedEpic, selectedEpicIssueId }) {
    state.epicSelectInProgress = false;
    state.selectedEpic = selectedEpic;
    state.selectedEpicIssueId = selectedEpicIssueId;
  },
  [types.RECEIVE_ISSUE_UPDATE_FAILURE](state) {
    state.epicSelectInProgress = false;
  },
};
