import * as types from './mutation_types';

export default {
  [types.SET_PAGE](state, page) {
    state.currentPage = page;
  },
  [types.REQUEST_DESIGNS](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_DESIGNS_SUCCESS](state, { data, perPage, total }) {
    state.isLoading = false;
    state.designs = data;
    state.pageSize = perPage;
    state.totalDesigns = total;
  },
  [types.RECEIVE_DESIGNS_ERROR](state) {
    state.isLoading = false;
    state.designs = [];
    state.pageSize = 0;
    state.totalDesigns = 0;
  },
};
