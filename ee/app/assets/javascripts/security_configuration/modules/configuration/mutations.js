import * as types from './mutation_types';

export default {
  [types.REQUEST_SECURITY_CONFIGURATION](state) {
    state.isLoading = true;
    state.errorLoading = false;
  },
  [types.RECEIVE_SECURITY_CONFIGURATION_SUCCESS](state, payload) {
    state.isLoading = false;
    state.errorLoading = false;
    state.configuration = payload;
  },
  [types.RECEIVE_SECURITY_CONFIGURATION_ERROR](state) {
    state.isLoading = false;
    state.errorLoading = true;
  },
};
