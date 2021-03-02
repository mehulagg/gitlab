import { find } from 'lodash';
import { ListType } from '~/boards/constants';
import gettersCE from '~/boards/stores/getters';

export default {
  ...gettersCE,

  isSwimlanesOn: (state) => {
    return Boolean(gon?.features?.swimlanes && state.isShowingEpicsSwimlanes);
  },

  getListByTypeId: (state) => ({ assigneeId, labelId, milestoneId }) => {
    if (assigneeId) {
      return find(
        state.boardLists,
        (l) => l.listType === ListType.assignee && l.assignee?.id === assigneeId,
      );
    }

    if (labelId) {
      return find(
        state.boardLists,
        (l) => l.listType === ListType.label && l.label?.id === labelId,
      );
    }

    if (milestoneId) {
      return find(
        state.boardLists,
        (l) => l.listType === ListType.milestone && l.milestone?.id === milestoneId,
      );
    }

    return null;
  },

  getColumnByMilestoneId: (state) => (milestoneId) => {
    if (!milestoneId) {
      return null;
    }
    return find(
      state.boardLists,
      (l) => l.listType === ListType.milestone && l.milestone?.id === milestoneId,
    );
  },

  getIssuesByEpic: (state, getters) => (listId, epicId) => {
    return getters
      .getBoardItemsByList(listId)
      .filter((issue) => issue.epic && issue.epic.id === epicId);
  },

  getUnassignedIssues: (state, getters) => (listId) => {
    return getters.getBoardItemsByList(listId).filter((i) => Boolean(i.epic) === false);
  },

  shouldUseGraphQL: (state) => {
    return state.isShowingEpicsSwimlanes || gon?.features?.graphqlBoardLists;
  },
};
