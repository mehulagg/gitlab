import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import * as types from './mutation_types';

export const setMilestonesEndpoint = ({ commit }, milestonesEndpoint) =>
  commit(types.SET_MILESTONES_ENDPOINT, milestonesEndpoint);

export const setLabelsEndpoint = ({ commit }, labelsEndpoint) =>
  commit(types.SET_LABELS_ENDPOINT, labelsEndpoint);

export const fetchMilestones = ({ commit, state }, search_title = '') => {
  commit(types.REQUEST_MILESTONES);

  return axios
    .get(state.milestonesEndpoint, { params: { search_title } })
    .then(({ data }) => {
      commit(types.RECEIVE_MILESTONES_SUCCESS, data);
    })
    .catch(({ response }) => {
      const { status } = response;
      commit(types.RECEIVE_MILESTONES_ERROR, status);
      createFlash(__('Failed to load milestones. Please try again.'));
    });
};

export const fetchLabels = ({ commit, state }, search = '') => {
  commit(types.REQUEST_LABELS);

  return axios
    .get(state.labelsEndpoint, { params: { search } })
    .then(({ data }) => {
      commit(types.RECEIVE_LABELS_SUCCESS, data);
    })
    .catch(({ response }) => {
      const { status } = response;
      commit(types.RECEIVE_LABELS_ERROR, status);
      createFlash(__('Failed to load labels. Please try again.'));
    });
};

export const setFilters = ({ commit, dispatch }, { labelNames, milestoneTitle }) => {
  commit(types.SET_FILTERS, {
    selectedLabels: labelNames,
    selectedMilestone: milestoneTitle,
  });

  dispatch('mergeRequests/setPage', 1, { root: true });
  dispatch('mergeRequests/fetchMergeRequests', null, { root: true });
};
