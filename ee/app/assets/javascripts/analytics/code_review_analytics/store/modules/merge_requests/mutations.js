import * as types from './mutation_types';

export default {
  [types.SET_PROJECT_ID](state, projectId) {
    state.projectId = projectId;
  },
  [types.REQUEST_MERGE_REQUESTS](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_MERGE_REQUESTS_SUCCESS](state, { pageInfo, mergeRequests }) {
    state.isLoading = false;
    state.errorCode = null;
    state.pageInfo = pageInfo;
    state.mergeRequests = mergeRequests;
  },
  [types.RECEIVE_MERGE_REQUESTS_ERROR](state, errorCode) {
    state.isLoading = false;
    state.errorCode = errorCode;
    state.pageInfo = {};
    state.mergeRequests = [];
  },
  [types.SET_PAGE](state, page) {
    state.pageInfo = { ...state.pageInfo, page };
  },
};
