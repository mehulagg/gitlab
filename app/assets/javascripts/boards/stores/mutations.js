import * as mutationTypes from './mutation_types';

const notImplemented = () => {
  /* eslint-disable-next-line @gitlab/require-i18n-strings */
  throw new Error('Not implemented!');
};

export default {
  [mutationTypes.SET_INITIAL_BOARD_DATA]: (state, data) => {
    const { boardType, ...endpoints } = data;
    state.endpoints = endpoints;
    state.boardType = boardType;
  },

  [mutationTypes.SET_ACTIVE_ID](state, id) {
    state.activeId = id;
  },

  [mutationTypes.REQUEST_ADD_LIST]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_ADD_LIST_SUCCESS]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_ADD_LIST_ERROR]: () => {
    notImplemented();
  },

  [mutationTypes.REQUEST_UPDATE_LIST]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_UPDATE_LIST_SUCCESS]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_UPDATE_LIST_ERROR]: () => {
    notImplemented();
  },

  [mutationTypes.REQUEST_REMOVE_LIST]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_REMOVE_LIST_SUCCESS]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_REMOVE_LIST_ERROR]: () => {
    notImplemented();
  },

  [mutationTypes.REQUEST_ISSUES_FOR_ALL_LISTS]: state => {
    state.isLoadingIssues = true;
  },

  [mutationTypes.RECEIVE_ISSUES_FOR_ALL_LISTS_SUCCESS]: (state, listIssues) => {
    state.issuesByListId = listIssues;
    state.isLoadingIssues = false;
  },

  [mutationTypes.RECEIVE_ISSUES_FOR_ALL_LISTS_FAILURE]: state => {
    state.listIssueFetchFailure = true;
    state.isLoadingIssues = false;
  },

  [mutationTypes.REQUEST_ADD_ISSUE]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_ADD_ISSUE_SUCCESS]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_ADD_ISSUE_ERROR]: () => {
    notImplemented();
  },

  [mutationTypes.REQUEST_MOVE_ISSUE]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_MOVE_ISSUE_SUCCESS]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_MOVE_ISSUE_ERROR]: () => {
    notImplemented();
  },

  [mutationTypes.REQUEST_UPDATE_ISSUE]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_UPDATE_ISSUE_SUCCESS]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_UPDATE_ISSUE_ERROR]: () => {
    notImplemented();
  },

  [mutationTypes.SET_CURRENT_PAGE]: () => {
    notImplemented();
  },

  [mutationTypes.TOGGLE_EMPTY_STATE]: () => {
    notImplemented();
  },
};
