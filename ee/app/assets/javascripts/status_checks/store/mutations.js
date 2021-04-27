import * as types from './types';

export default {
  [types.SET_LOADING](state, isLoading) {
    state.isLoading = isLoading;
  },
  [types.SET_STATUS_CHECKS](state, settings) {
    state.hasLoaded = true;
    state.services = settings.services;
  },
};
