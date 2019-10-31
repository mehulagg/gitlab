import * as types from './mutation_types';

export default {
  [types.SET_ENDPOINT](state, endpoint) {
    state.endpoint = endpoint;
  },
  [types.SET_FILTER](state, filterIndex) {
    state.currentFilterIndex = filterIndex;
  },
  [types.SET_SEARCH](state, search) {
    state.searchFilter = search;
  },
  [types.REQUEST_DESIGNS](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_DESIGNS_SUCCESS](state, data) {
    state.isLoading = false;
    state.designs = data;
  },
  [types.RECEIVE_DESIGNS_ERROR](state, error) {
    state.isLoading = false;
    state.error = error;
  }
};