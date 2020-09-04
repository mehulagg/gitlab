import Vue from 'vue';
import { sortBy } from 'lodash';
import * as mutationTypes from './mutation_types';
import { __ } from '~/locale';

const notImplemented = () => {
  /* eslint-disable-next-line @gitlab/require-i18n-strings */
  throw new Error('Not implemented!');
};

export default {
  [mutationTypes.SET_INITIAL_BOARD_DATA](state, data) {
    const { boardType, disabled, showPromotion, ...endpoints } = data;
    state.endpoints = endpoints;
    state.boardType = boardType;
    state.disabled = disabled;
    state.showPromotion = showPromotion;
  },

  [mutationTypes.RECEIVE_LISTS]: (state, lists) => {
    state.boardLists = lists;
  },

  [mutationTypes.SET_ACTIVE_ID](state, { id, sidebarType }) {
    state.activeId = id;
    state.sidebarType = sidebarType;
  },

  [mutationTypes.SET_FILTERS](state, filterParams) {
    state.filterParams = filterParams;
  },

  [mutationTypes.CREATE_LIST_FAILURE]: state => {
    state.error = __('An error occurred while creating the list. Please try again.');
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

  [mutationTypes.MOVE_LIST]: (state, { movedList, listAtNewIndex }) => {
    const { boardLists } = state;
    const movedListIndex = state.boardLists.findIndex(l => l.id === movedList.id);
    Vue.set(boardLists, movedListIndex, movedList);
    Vue.set(boardLists, movedListIndex.position + 1, listAtNewIndex);
    Vue.set(state, 'boardLists', sortBy(boardLists, 'position'));
  },

  [mutationTypes.UPDATE_LIST_FAILURE]: (state, backupList) => {
    state.error = __('An error occurred while updating the list. Please try again.');
    Vue.set(state, 'boardLists', backupList);
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

  [mutationTypes.RECEIVE_ISSUES_FOR_ALL_LISTS_SUCCESS]: (state, { listData, issues }) => {
    state.issuesByListId = listData;
    console.log(issues);
    state.issues = issues;
    state.isLoadingIssues = false;
  },

  [mutationTypes.UPDATE_ISSUE_BY_ID]: (state, { issueId, prop, value }) => {
    if (!state.issues[issueId]) {
      /* eslint-disable-next-line @gitlab/require-i18n-strings */
      throw new Error('No issue found.');
    }

    Vue.set(state.issues[issueId], prop, value);
  },

  [mutationTypes.RECEIVE_ISSUES_FOR_ALL_LISTS_FAILURE]: state => {
    state.error = __('An error occurred while fetching the board issues. Please reload the page.');
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
