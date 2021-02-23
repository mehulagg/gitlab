import * as types from './mutation_types';

export default {
  [types.REQUEST_NODES](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_NODES_SUCCESS](state, data) {
    state.isLoading = false;
    state.nodes = data;
  },
  [types.RECEIVE_NODES_ERROR](state) {
    state.isLoading = false;
    state.nodes = [];
  },
};
