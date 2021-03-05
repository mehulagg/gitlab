import { issuableTypes } from '~/boards/constants';
import gettersCE from '~/boards/stores/getters';

export default {
  ...gettersCE,

  isSwimlanesOn: (state) => {
    return Boolean(gon?.features?.swimlanes && state.isShowingEpicsSwimlanes);
  },
  getIssuesByEpic: (state, getters) => (listId, epicId) => {
    return getters
      .getBoardItemsByList(listId)
      .filter((issue) => issue.epic && issue.epic.id === epicId);
  },

  getUnassignedIssues: (state, getters) => (listId) => {
    return getters.getBoardItemsByList(listId).filter((i) => Boolean(i.epic) === false);
  },

  isEpicBoard: (state) => {
    return state.issuableType === issuableTypes.epic;
  },

  shouldUseGraphQL: (state) => {
    return state.isShowingEpicsSwimlanes || gon?.features?.graphqlBoardLists;
  },
};
