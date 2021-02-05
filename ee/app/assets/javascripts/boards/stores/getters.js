import gettersCE from '~/boards/stores/getters';

export default {
  ...gettersCE,

  isSwimlanesOn: (state) => {
    return Boolean(gon?.features?.swimlanes && state.isShowingEpicsSwimlanes);
  },
  getIssuesByEpic: (state, getters) => (listId, epicId) => {
    return getters
      .getIssuesByList(listId)
      .filter((issue) => issue.epic && issue.epic.id === epicId);
  },

  getUnassignedIssues: (state, getters) => (listId) => {
    return getters.getIssuesByList(listId).filter((i) => Boolean(i.epic) === false);
  },

  shouldUseGraphQL: (state) => {
    return state.isShowingEpicsSwimlanes || gon?.features?.graphqlBoardLists;
  },
};
