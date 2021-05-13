import * as types from './mutation_types';

export default {
  [types.SET_LOADING](state, isLoading) {
    state.isLoading = isLoading;
  },
  [types.SET_SETTINGS](state, settings) {
    state.settings = settings;
  },
  [types.SET_STATUS_CHECKS](state, statusChecks) {
    state.statusChecks = statusChecks;
  },
};
