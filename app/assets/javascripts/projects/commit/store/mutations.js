import * as types from './mutation_types';

export default {
  [types.REQUEST_BRANCHES](state) {
    state.isFetching = true;
  },

  [types.RECEIVE_BRANCHES_SUCCESS](state, branches) {
    state.isFetching = false;
    state.branches = branches;
    state.branches.unshift(state.branch);
  },

  [types.REQUEST_PROJECTS](state) {
    state.isFetching = true;
  },

  [types.RECEIVE_PROJECTS_SUCCESS](state, projects) {
    state.isFetching = false;
    state.projects = projects;
    state.projects.unshift(state.project);
  },

  [types.CLEAR_MODAL](state) {
    state.branch = state.defaultBranch;
    state.project = state.defaultProject;
  },

  [types.SET_BRANCH](state, branch) {
    state.branch = branch;
  },

  [types.SET_SELECTED_BRANCH](state, branch) {
    state.selectedBranch = branch;
  },

  [types.SET_PROJECT](state, project) {
    state.project = project;
  },

  [types.SET_SELECTED_PROJECT](state, project) {
    state.selectedProject = project;
  },
};
