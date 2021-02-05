import * as types from './mutation_types';

export default {
  [types.REQUEST_SETTINGS](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_SETTINGS_SUCCESS](state, data) {
    state.preventAuthorApproval = !data.allow_author_approval;
    state.isLoading = false;
  },
  [types.RECEIVE_SETTINGS_ERROR](state) {
    state.isLoading = false;
  },
  [types.UPDATE_PREVENT_AUTHOR_APPROVAL](state, value) {
    state.preventAuthorApproval = value;
  },
};
