import gettersCE from '~/boards/stores/getters';

export default {
  ...gettersCE,

  getIssuesByEpic: (state, getters) => (listId, epicId) => {
    return getters.getIssuesByList(listId).filter(issue => issue.epic && issue.epic.id === epicId);
  },

  getUnassignedIssues: (state, getters) => listId => {
    return getters.getIssuesByList(listId).filter(i => Boolean(i.epic) === false);
  },

  getEpicById: state => epicId => {
    return state.epics.find(epic => epic.id === epicId);
  },

  shouldUseGraphQL: state => {
    return (
      (gon?.features?.boardsWithSwimlanes && state.isShowingEpicsSwimlanes) ||
      gon?.features?.graphqlBoardLists
    );
  },
};
