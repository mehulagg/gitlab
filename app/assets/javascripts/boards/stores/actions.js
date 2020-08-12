import * as types from './mutation_types';

const notImplemented = () => {
  /* eslint-disable-next-line @gitlab/require-i18n-strings */
  throw new Error('Not implemented!');
};

export default {
  setInitialBoardData: ({ commit }, data) => {
    commit(types.SET_INITIAL_BOARD_DATA, data);
  },

  setActiveId({ commit }, id) {
    commit(types.SET_ACTIVE_ID, id);
  },

  fetchLists: () => {
    notImplemented();
  },

  generateDefaultLists: () => {
    notImplemented();
  },

  createList: () => {
    notImplemented();
  },

  updateList: () => {
    notImplemented();
  },

  deleteList: () => {
    notImplemented();
  },

  fetchIssuesForList: () => {
    notImplemented();
  },

  moveIssue: () => {
    notImplemented();
  },

  createNewIssue: () => {
    notImplemented();
  },

  fetchBacklog: () => {
    notImplemented();
  },

  bulkUpdateIssues: () => {
    notImplemented();
  },

  fetchIssue: () => {
    notImplemented();
  },

  toggleIssueSubscription: () => {
    notImplemented();
  },

  showPage: () => {
    notImplemented();
  },

  toggleEmptyState: () => {
    notImplemented();
  },
};
