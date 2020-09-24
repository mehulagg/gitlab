import gettersCE from '~/boards/stores/getters';

export default {
  ...gettersCE,

  getIssuesByEpic: (state, getters) => (listId, epicId) => {
    return getters.getIssues(listId).filter(issue => issue.epic && issue.epic.id === epicId);
  },

  getUnassignedIssues: (state, getters) => listId => {
    return getters.getIssues(listId).filter(i => Boolean(i.epic) === false);
  },
};
