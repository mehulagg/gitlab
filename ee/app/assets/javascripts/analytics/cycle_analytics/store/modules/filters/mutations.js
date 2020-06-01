import * as types from './mutation_types';

export default {
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
    state.milestones.errorCode = null;
  },
  [types.RECEIVE_MILESTONES_ERROR](state, errorCode) {
    state.milestones.isLoading = false;
    state.milestones.errorCode = errorCode;
    state.milestones.data = [];
  },
  [types.REQUEST_LABELS](state) {
    state.labels.isLoading = true;
  },
  [types.RECEIVE_LABELS_SUCCESS](state, data) {
    state.labels.isLoading = false;
    state.labels.data = data;
    state.labels.errorCode = null;
  },
  [types.RECEIVE_LABELS_ERROR](state, errorCode) {
    state.labels.isLoading = false;
    state.labels.errorCode = errorCode;
    state.labels.data = [];
  },
  [types.REQUEST_AUTHORS](state) {
    state.authors.isLoading = true;
  },
  [types.RECEIVE_AUTHORS_SUCCESS](state, data) {
    state.authors.isLoading = false;
    state.authors.data = data;
    state.authors.errorCode = null;
  },
  [types.RECEIVE_AUTHORS_ERROR](state, errorCode) {
    state.authors.isLoading = false;
    state.authors.errorCode = errorCode;
    state.authors.data = [];
  },
  [types.SET_FILTERS](state, { selectedLabels, selectedMilestone }) {
    state.labels.selected = selectedLabels;
    state.milestones.selected = selectedMilestone;
  },
};
