import gettersCE from '~/boards/stores/getters';

export default {
  ...gettersCE,

  issuesByEpic: (state, getters) => (listId, epicId) => {
    return getters.issues(listId).filter(issue => issue.epic && issue.epic.id === epicId);
  },

  unassignedIssues: (state, getters) => listId => {
    return getters.issues(listId).filter(i => Boolean(i.epic) === false);
  },

  epicById: state => epicId => {
    return state.epics.find(epic => epic.id === epicId);
  },

  shouldUseGraphQL: state => {
    return (
      (gon?.features?.boardsWithSwimlanes && state.isShowingEpicsSwimlanes) ||
      gon?.features?.graphqlBoardLists
    );
  },
};
