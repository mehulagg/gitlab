import * as types from './mutation_types';

export default {
  [types.SET_ENDPOINT](state, endpoint) {
    state.endpoint = endpoint;
  },
  [types.REQUEST_METRICS](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_METRICS_SUCCESS](state, response) {
    // Make sure to clean previous state in case it was an error
    state.hasError = false;
    state.isLoading = false;

    state.newMetrics = response.new_metrics || [];
    state.existingMetrics = response.existing_metrics || [];
    state.removedMetrics = response.removed_metrics || [];

    state.numberOfChanges =
      state.existingMetrics.filter((metric) => metric.previous_value !== undefined).length +
      state.newMetrics.length +
      state.removedMetrics.length;
  },
  [types.RECEIVE_METRICS_ERROR](state) {
    state.isLoading = false;
    state.hasError = true;

    state.newMetrics = [];
    state.existingMetrics = [];
    state.removedMetrics = [];

    state.numberOfChanges = 0;
  },
};
