import * as types from './mutation_types';

export default {
  [types.SET_FILTER](state, filterIndex) {
    state.paginationData.page = 1;
    state.currentFilterIndex = filterIndex;
  },
  [types.SET_SEARCH](state, search) {
    state.paginationData.page = 1;
    state.searchFilter = search;
  },
  [types.SET_PAGE](state, page) {
    state.paginationData.page = page;
  },
  [types.REQUEST_REPLICABLE_ITEMS](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_REPLICABLE_ITEMS_SUCCESS](state, { data, pagination }) {
    state.isLoading = false;
    state.replicableItems = data;
    state.paginationData = pagination;
  },
  [types.RECEIVE_REPLICABLE_ITEMS_ERROR](state) {
    state.isLoading = false;
    state.replicableItems = [];
    state.paginationData = {};
  },
  [types.REQUEST_INITIATE_ALL_REPLICABLE_SYNCS](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_INITIATE_ALL_REPLICABLE_SYNCS_SUCCESS](state) {
    state.isLoading = false;
  },
  [types.RECEIVE_INITIATE_ALL_REPLICABLE_SYNCS_ERROR](state) {
    state.isLoading = false;
  },
  [types.REQUEST_INITIATE_REPLICABLE_SYNC](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_INITIATE_REPLICABLE_SYNC_SUCCESS](state) {
    state.isLoading = false;
  },
  [types.RECEIVE_INITIATE_REPLICABLE_SYNC_ERROR](state) {
    state.isLoading = false;
  },
};
