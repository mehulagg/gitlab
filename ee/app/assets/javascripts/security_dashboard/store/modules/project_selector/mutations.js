import * as types from './mutation_types';

export default {
  [types.SET_PROJECT_ENDPOINTS](state, endpoints) {
    state.projectEndpoints.add = endpoints.add;
    state.projectEndpoints.list = endpoints.list;
  },
  [types.SET_SEARCH_QUERY](state, query) {
    state.searchQuery = query;
  },
  [types.SELECT_PROJECT](state, project) {
    if (!state.selectedProjects.some((p) => p.id === project.id)) {
      state.selectedProjects.push(project);
    }
  },
  [types.DESELECT_PROJECT](state, project) {
    state.selectedProjects = state.selectedProjects.filter((p) => p.id !== project.id);
  },
  [types.REQUEST_ADD_PROJECTS](state) {
    state.isAddingProjects = true;
  },
  [types.RECEIVE_ADD_PROJECTS_SUCCESS](state) {
    state.isAddingProjects = false;
  },
  [types.RECEIVE_ADD_PROJECTS_ERROR](state) {
    state.isAddingProjects = false;
  },
  [types.REQUEST_REMOVE_PROJECT](state) {
    state.isRemovingProject = true;
  },
  [types.RECEIVE_REMOVE_PROJECT_SUCCESS](state) {
    state.isRemovingProject = false;
  },
  [types.RECEIVE_REMOVE_PROJECT_ERROR](state) {
    state.isRemovingProject = false;
  },
  [types.REQUEST_PROJECTS](state) {
    state.isLoadingProjects = true;
  },
  [types.RECEIVE_PROJECTS_SUCCESS](state, projects) {
    state.projects = projects;
    state.isLoadingProjects = false;
  },
  [types.RECEIVE_PROJECTS_ERROR](state) {
    state.projects = [];
    state.isLoadingProjects = false;
  },
  [types.CLEAR_SEARCH_RESULTS](state) {
    state.projectSearchResults = [];
    state.selectedProjects = [];
  },
  [types.REQUEST_SEARCH_RESULTS](state) {
    state.messages.minimumQuery = false;
    state.searchCount += 1;
  },
  [types.RECEIVE_SEARCH_RESULTS_SUCCESS](state, { data, pageInfo }) {
    state.projectSearchResults = data;
    state.pageInfo = pageInfo;

    state.messages.noResults = state.projectSearchResults.length === 0;
    state.messages.searchError = false;
    state.messages.minimumQuery = false;

    state.searchCount = Math.max(0, state.searchCount - 1);
  },
  [types.RECEIVE_SEARCH_RESULTS_ERROR](state) {
    state.projectSearchResults = [];

    state.messages.noResults = false;
    state.messages.searchError = true;
    state.messages.minimumQuery = false;

    state.searchCount = Math.max(0, state.searchCount - 1);
  },
  [types.SET_MINIMUM_QUERY_MESSAGE](state) {
    state.projectSearchResults = [];
    state.pageInfo.total = 0;

    state.messages.noResults = false;
    state.messages.searchError = false;
    state.messages.minimumQuery = true;

    state.searchCount = Math.max(0, state.searchCount - 1);
  },
  [types.RECEIVE_NEXT_PAGE_SUCCESS](state, { data, pageInfo }) {
    state.projectSearchResults = state.projectSearchResults.concat(data);

    state.pageInfo = pageInfo;
  },
};
