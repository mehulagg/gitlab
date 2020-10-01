import Api from '~/api';
import * as types from './mutation_types';

export const setProjectId = ({ commit }, projectId) => commit(types.SET_PROJECT_ID, projectId);
export const setGroupId = ({ commit }, groupId) => commit(types.SET_GROUP_ID, groupId);

export const setSelectedMilestones = ({ commit }, selectedMilestones) =>
  commit(types.SET_SELECTED_MILESTONES, selectedMilestones);

export const search = ({ dispatch, commit }, query) => {
  commit(types.SET_QUERY, query);

  dispatch('searchMilestones');
};

export const searchMilestones = ({ commit, state }) => {
  commit(types.REQUEST_START);

  const options = {
    search: state.query,
    scope: 'milestones',
  };

  Api.projectSearch(state.projectId, options)
    .then(response => {
      commit(types.RECEIVE_MILESTONES_SUCCESS, response);
    })
    .catch(error => {
      commit(types.RECEIVE_MILESTONES_ERROR, error);
    })
    .finally(() => {
      commit(types.REQUEST_FINISH);
    });
};
