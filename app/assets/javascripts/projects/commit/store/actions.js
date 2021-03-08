import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { PROJECT_BRANCHES_ERROR, PROJECTS_FETCH_ERROR } from '../constants';
import * as types from './mutation_types';

export const clearModal = ({ commit }) => {
  commit(types.CLEAR_MODAL);
};

export const requestBranches = ({ commit }) => {
  commit(types.REQUEST_BRANCHES);
};

export const fetchBranches = ({ commit, dispatch, state }, query) => {
  dispatch('requestBranches');

  return axios
    .get(state.branchesEndpoint, {
      params: { search: query },
    })
    .then((res) => {
      commit(types.RECEIVE_BRANCHES_SUCCESS, res.data);
    })
    .catch(() => {
      createFlash({ message: PROJECT_BRANCHES_ERROR });
    });
};

export const setBranch = ({ commit, dispatch }, branch) => {
  commit(types.SET_BRANCH, branch);
  dispatch('setSelectedBranch', branch);
};

export const setSelectedBranch = ({ commit }, branch) => {
  commit(types.SET_SELECTED_BRANCH, branch);
};

export const requestProjects = ({ commit }) => {
  commit(types.REQUEST_PROJECTS);
};

export const fetchProjects = ({ commit, dispatch, state }, query) => {
  dispatch('requestProjects');

  return axios
    .get(state.projectsEndpoint, {
      params: { search: query },
    })
    .then((res) => {
      commit(types.RECEIVE_PROJECTS_SUCCESS, res.data);
    })
    .catch(() => {
      createFlash({ message: PROJECTS_FETCH_ERROR });
    });
};

export const setProject = ({ commit, dispatch }, project) => {
  commit(types.SET_PROJECT, project);
  dispatch('setSelectedProject', project);
};

export const setSelectedProject = ({ commit }, project) => {
  commit(types.SET_SELECTED_PROJECT, project);
};
