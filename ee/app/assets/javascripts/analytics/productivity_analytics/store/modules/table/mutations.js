import { tableSortOrder } from '../../../constants';
import * as types from './mutation_types';

export default {
  [types.REQUEST_MERGE_REQUESTS](state) {
    state.isLoadingTable = true;
  },
  [types.RECEIVE_MERGE_REQUESTS_SUCCESS](state, { pageInfo, mergeRequests }) {
    state.isLoadingTable = false;
    state.errorCode = null;
    state.pageInfo = pageInfo;
    state.mergeRequests = mergeRequests;
  },
  [types.RECEIVE_MERGE_REQUESTS_ERROR](state, errCode) {
    state.isLoadingTable = false;
    state.errorCode = errCode;
    state.pageInfo = {};
    state.mergeRequests = [];
  },
  [types.SET_SORT_FIELD](state, sortField) {
    state.sortField = sortField;
  },
  [types.TOGGLE_SORT_ORDER](state) {
    state.sortOrder =
      state.sortOrder === tableSortOrder.asc.value
        ? tableSortOrder.desc.value
        : tableSortOrder.asc.value;
  },
  [types.SET_COLUMN_METRIC](state, columnMetric) {
    state.columnMetric = columnMetric;
  },
  [types.SET_PAGE](state, page) {
    state.pageInfo = { ...state.pageInfo, page };
  },
};
