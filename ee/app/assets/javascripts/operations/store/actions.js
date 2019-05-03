import Visibility from 'visibilityjs';
import Api from '~/api';
import axios from '~/lib/utils/axios_utils';
import Poll from '~/lib/utils/poll';
import createFlash from '~/flash';
import { __, s__, n__, sprintf } from '~/locale';
import _ from 'underscore';
import * as types from './mutation_types';

const API_MINIMUM_QUERY_LENGTH = 3;

let eTagPoll;

export const clearProjectsEtagPoll = () => {
  eTagPoll = null;
};
export const stopProjectsPolling = () => {
  if (eTagPoll) eTagPoll.stop();
};
export const restartProjectsPolling = () => {
  if (eTagPoll) eTagPoll.restart();
};
export const forceProjectsRequest = () => {
  if (eTagPoll) eTagPoll.makeRequest();
};

export const addProjectsToDashboard = ({ state, dispatch }) =>
  axios
    .post(state.projectEndpoints.add, {
      project_ids: state.selectedProjects.map(p => p.id),
    })
    .then(response => dispatch('receiveAddProjectsToDashboardSuccess', response.data))
    .catch(() => dispatch('receiveAddProjectsToDashboardError'));

export const toggleSelectedProject = ({ commit, state }, project) => {
  if (!_.findWhere(state.selectedProjects, { id: project.id })) {
    commit(types.ADD_SELECTED_PROJECT, project);
  } else {
    commit(types.REMOVE_SELECTED_PROJECT, project);
  }
};

export const clearSearchResults = ({ commit }) => {
  commit(types.CLEAR_SEARCH_RESULTS);
};

export const receiveAddProjectsToDashboardSuccess = ({ dispatch, state }, data) => {
  const { added, invalid } = data;

  if (invalid.length) {
    const projectNames = state.selectedProjects.reduce((accumulator, project) => {
      if (invalid.includes(project.id)) {
        accumulator.push(project.name);
      }
      return accumulator;
    }, []);
    let invalidProjects;
    if (projectNames.length > 2) {
      invalidProjects = `${projectNames.slice(0, -1).join(', ')}, and ${projectNames.pop()}`;
    } else if (projectNames.length > 1) {
      invalidProjects = projectNames.join(' and ');
    } else {
      [invalidProjects] = projectNames;
    }
    createFlash(
      sprintf(
        s__(
          'OperationsDashboard|Unable to add %{invalidProjects}. The Operations Dashboard is available for public projects, and private projects in groups with a Gold plan.',
        ),
        {
          invalidProjects,
        },
      ),
    );
  }

  if (added.length) {
    dispatch('forceProjectsRequest');
  }
};

export const receiveAddProjectsToDashboardError = ({ state }) => {
  createFlash(
    sprintf(__('Something went wrong, unable to add %{project} to dashboard'), {
      project: n__('project', 'projects', state.selectedProjects.length),
    }),
  );
};

export const fetchProjects = ({ state, dispatch }) => {
  if (eTagPoll) return;

  dispatch('requestProjects');

  eTagPoll = new Poll({
    resource: {
      fetchProjects: () => axios.get(state.projectEndpoints.list),
    },
    method: 'fetchProjects',
    successCallback: ({ data }) => dispatch('receiveProjectsSuccess', data),
    errorCallback: () => dispatch('receiveProjectsError'),
  });

  if (!Visibility.hidden()) {
    eTagPoll.makeRequest();
  }

  Visibility.change(() => {
    if (!Visibility.hidden()) {
      dispatch('restartProjectsPolling');
    } else {
      dispatch('stopProjectsPolling');
    }
  });
};

export const requestProjects = ({ commit }) => {
  commit(types.REQUEST_PROJECTS);
};

export const receiveProjectsSuccess = ({ commit }, data) => {
  commit(types.RECEIVE_PROJECTS_SUCCESS, data.projects);
};

export const receiveProjectsError = ({ commit }) => {
  commit(types.RECEIVE_PROJECTS_ERROR);
  createFlash(__('Something went wrong, unable to get operations projects'));
};

export const removeProject = ({ dispatch }, removePath) => {
  axios
    .delete(removePath)
    .then(() => dispatch('receiveRemoveProjectSuccess'))
    .catch(() => dispatch('receiveRemoveProjectError'));
};

export const receiveRemoveProjectSuccess = ({ dispatch }) => dispatch('forceProjectsRequest');

export const receiveRemoveProjectError = () => {
  createFlash(__('Something went wrong, unable to remove project'));
};

export const setSearchQuery = ({ commit }, query) => commit(types.SET_SEARCH_QUERY, query);

export const fetchSearchResults = ({ state, dispatch }) => {
  dispatch('requestSearchResults');

  if (!state.searchQuery) {
    dispatch('receiveSearchResultsError');
  } else if (state.searchQuery.lengh < API_MINIMUM_QUERY_LENGTH) {
    dispatch('receiveSearchResultsError', 'minimumQuery');
  } else {
    Api.projects(state.searchQuery, {})
      .then(results => dispatch('receiveSearchResultsSuccess', results))
      .catch(() => dispatch('receiveSearchResultsError'));
  }
};

export const requestSearchResults = ({ commit }) => commit(types.REQUEST_SEARCH_RESULTS);

export const receiveSearchResultsSuccess = ({ commit }, results) => {
  commit(types.RECEIVE_SEARCH_RESULTS_SUCCESS, results);
};

export const receiveSearchResultsError = ({ commit }) => {
  commit(types.RECEIVE_SEARCH_RESULTS_ERROR);
};

export const setProjectEndpoints = ({ commit }, endpoints) => {
  commit(types.SET_PROJECT_ENDPOINT_LIST, endpoints.list);
  commit(types.SET_PROJECT_ENDPOINT_ADD, endpoints.add);
};

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
