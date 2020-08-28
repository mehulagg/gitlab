import * as types from './mutation_types';

export default {
  [types.SET_SELECTED_FILTERS](state, params) {
    const {
      selectedAuthor = null,
      selectedMilestone = null,
      selectedAssignees = [],
      selectedLabels = [],
    } = params;
    state.authors.selected = selectedAuthor;
    state.assignees.selected = selectedAssignees;
    state.milestones.selected = selectedMilestone;
    state.labels.selected = selectedLabels;
  },
  [types.SET_MILESTONES_ENDPOINT](state, milestonesEndpoint) {
    state.milestonesEndpoint = milestonesEndpoint;
  },
  [types.SET_LABELS_ENDPOINT](state, labelsEndpoint) {
    state.labelsEndpoint = labelsEndpoint;
  },
  [types.REQUEST_MILESTONES](state) {
    state.milestones.isLoading = true;
  },
  [types.RECEIVE_MILESTONES_SUCCESS](state, data) {
    state.milestones.isLoading = false;
    state.milestones.data = data;
  },
  [types.RECEIVE_MILESTONES_ERROR](state) {
    state.milestones.isLoading = false;
    state.milestones.data = [];
  },
  [types.REQUEST_LABELS](state) {
    state.labels.isLoading = true;
  },
  [types.RECEIVE_LABELS_SUCCESS](state, data) {
    state.labels.isLoading = false;
    state.labels.data = data;
  },
  [types.RECEIVE_LABELS_ERROR](state) {
    state.labels.isLoading = false;
    state.labels.data = [];
  },
  [types.REQUEST_AUTHORS](state) {
    state.authors.isLoading = true;
  },
  [types.RECEIVE_AUTHORS_SUCCESS](state, data) {
    state.authors.isLoading = false;
    state.authors.data = data;
  },
  [types.RECEIVE_AUTHORS_ERROR](state) {
    state.authors.isLoading = false;
    state.authors.data = [];
  },
  [types.REQUEST_ASSIGNEES](state) {
    state.assignees.isLoading = true;
  },
  [types.RECEIVE_ASSIGNEES_SUCCESS](state, data) {
    state.assignees.isLoading = false;
    state.assignees.data = data;
  },
  [types.RECEIVE_ASSIGNEES_ERROR](state) {
    state.assignees.isLoading = false;
    state.assignees.data = [];
  },
};
