import Api from '~/api';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { __, s__, sprintf } from '~/locale';
import * as types from './mutation_types';
import addPageInfo from './utils/add_page_info';

const API_MINIMUM_QUERY_LENGTH = 3;

const searchProjects = (searchQuery, searchOptions) =>
  Api.projects(searchQuery, searchOptions).then(addPageInfo);

export const toggleSelectedProject = ({ commit, state }, project) => {
  const isProject = ({ id }) => id === project.id;

  if (state.selectedProjects.some(isProject)) {
    commit(types.DESELECT_PROJECT, project);
  } else {
    commit(types.SELECT_PROJECT, project);
  }
};

export const clearSearchResults = ({ commit }) => {
  commit(types.CLEAR_SEARCH_RESULTS);
};

export const setSearchQuery = ({ commit }, query) => {
  commit(types.SET_SEARCH_QUERY, query);
};

export const setProjectEndpoints = ({ commit }, endpoints) => {
  commit(types.SET_PROJECT_ENDPOINTS, endpoints);
};

export const addProjects = ({ state, dispatch }) => {
  dispatch('requestAddProjects');

  return axios
    .post(state.projectEndpoints.add, {
      project_ids: state.selectedProjects.map((p) => p.id),
    })
    .then((response) => dispatch('receiveAddProjectsSuccess', response.data))
    .catch(() => dispatch('receiveAddProjectsError'))
    .finally(() => dispatch('clearSearchResults'));
};

export const requestAddProjects = ({ commit }) => {
  commit(types.REQUEST_ADD_PROJECTS);
};

export const receiveAddProjectsSuccess = ({ commit, dispatch, state }, data) => {
  const { added, invalid } = data;

  commit(types.RECEIVE_ADD_PROJECTS_SUCCESS);

  if (invalid.length) {
    const [firstProject, secondProject, ...rest] = state.selectedProjects
      .filter((project) => invalid.includes(project.id))
      .map((project) => project.name);
    const translationValues = {
      firstProject,
      secondProject,
      rest: rest.join(', '),
    };
    let invalidProjects;
    if (rest.length > 0) {
      invalidProjects = sprintf(
        s__('SecurityReports|%{firstProject}, %{secondProject}, and %{rest}'),
        translationValues,
      );
    } else if (secondProject) {
      invalidProjects = sprintf(
        s__('SecurityReports|%{firstProject} and %{secondProject}'),
        translationValues,
      );
    } else {
      invalidProjects = firstProject;
    }
    createFlash({
      message: sprintf(s__('SecurityReports|Unable to add %{invalidProjects}'), {
        invalidProjects,
      }),
    });
  }

  if (added.length) {
    dispatch('fetchProjects');
  }
};

export const receiveAddProjectsError = ({ commit }) => {
  commit(types.RECEIVE_ADD_PROJECTS_ERROR);

  createFlash({
    message: __('Something went wrong, unable to add projects to dashboard'),
  });
};

export const fetchProjects = ({ state, dispatch }) => {
  dispatch('requestProjects');

  return axios
    .get(state.projectEndpoints.list)
    .then(({ data }) => {
      dispatch('receiveProjectsSuccess', data);
    })
    .catch(() => dispatch('receiveProjectsError'));
};

export const requestProjects = ({ commit }) => {
  commit(types.REQUEST_PROJECTS);
};

export const receiveProjectsSuccess = ({ commit }, { projects }) => {
  commit(types.RECEIVE_PROJECTS_SUCCESS, projects);
};

export const receiveProjectsError = ({ commit }) => {
  commit(types.RECEIVE_PROJECTS_ERROR);

  createFlash({
    message: __('Something went wrong, unable to get projects'),
  });
};

export const removeProject = ({ dispatch }, removePath) => {
  dispatch('requestRemoveProject');

  return axios
    .delete(removePath)
    .then(() => {
      dispatch('receiveRemoveProjectSuccess');
    })
    .catch(() => dispatch('receiveRemoveProjectError'));
};

export const requestRemoveProject = ({ commit }) => {
  commit(types.REQUEST_REMOVE_PROJECT);
};

export const receiveRemoveProjectSuccess = ({ commit, dispatch }) => {
  commit(types.RECEIVE_REMOVE_PROJECT_SUCCESS);
  dispatch('fetchProjects');
};

export const receiveRemoveProjectError = ({ commit }) => {
  commit(types.RECEIVE_REMOVE_PROJECT_ERROR);

  createFlash({
    message: __('Something went wrong, unable to delete project'),
  });
};

export const fetchSearchResults = ({ state, dispatch, commit }) => {
  const { searchQuery } = state;
  dispatch('requestSearchResults');

  if (!searchQuery || searchQuery.length < API_MINIMUM_QUERY_LENGTH) {
    return dispatch('setMinimumQueryMessage');
  }

  return searchProjects(searchQuery)
    .then((payload) => commit(types.RECEIVE_SEARCH_RESULTS_SUCCESS, payload))
    .catch(() => dispatch('receiveSearchResultsError'));
};

export const requestSearchResults = ({ commit }) => {
  commit(types.REQUEST_SEARCH_RESULTS);
};

export const receiveSearchResultsError = ({ commit }) => {
  commit(types.RECEIVE_SEARCH_RESULTS_ERROR);
};

export const setMinimumQueryMessage = ({ commit }) => {
  commit(types.SET_MINIMUM_QUERY_MESSAGE);
};
