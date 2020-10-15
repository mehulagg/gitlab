import Api from '~/api';
import * as types from './mutation_types';

export const setProjectId = ({ commit }, projectId) => commit(types.SET_PROJECT_ID, projectId);

export const setSelectedMilestones = ({ commit }, selectedMilestone) =>
  commit(types.SET_SELECTED_MILESTONES, selectedMilestone);

export const search = ({ dispatch, commit }, query) => {
  commit(types.SET_QUERY, query);

  dispatch('searchMilestones');
};

export const fetchMilestones = ({ commit, state }) => {
  commit(types.REQUEST_START);

  Api.projectMilestones(state.projectId)
    .then(response => {
      commit(types.RECEIVE_PROJECT_MILESTONES_SUCCESS, response);
    })
    .catch(error => {
      commit(types.RECEIVE_PROJECT_MILESTONES_ERROR, error);
    })
    .finally(() => {
      commit(types.REQUEST_FINISH);
    });
};

export const searchMilestones = ({ commit, state }) => {
  commit(types.REQUEST_START);

  const options = {
    search: state.query,
    scope: 'milestones',
  };

  Api.projectSearch(state.projectId, options)
    .then(response => {
      commit(types.RECEIVE_PROJECT_MILESTONES_SUCCESS, response);
    })
    .catch(error => {
      commit(types.RECEIVE_PROJECT_MILESTONES_ERROR, error);
    })
    .finally(() => {
      commit(types.REQUEST_FINISH);
    });
};
