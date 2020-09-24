import {
  REQUEST_UNSCANNED_PROJECTS,
  RECEIVE_UNSCANNED_PROJECTS_SUCCESS,
  RECEIVE_UNSCANNED_PROJECTS_ERROR,
} from './mutation_types';

export default {
  [REQUEST_UNSCANNED_PROJECTS](state) {
    state.isLoading = true;
  },
  [RECEIVE_UNSCANNED_PROJECTS_SUCCESS](state, projects) {
    state.isLoading = false;
    state.projects = projects;
  },
  [RECEIVE_UNSCANNED_PROJECTS_ERROR](state) {
    state.isLoading = false;
  },
};
