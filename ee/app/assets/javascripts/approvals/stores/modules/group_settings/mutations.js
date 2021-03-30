import * as types from './mutation_types';

export default {
  [types.REQUEST_SETTINGS](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_SETTINGS_SUCCESS](state, data) {
    state.settings.preventAuthorApproval = !data.allow_author_approval;
    state.settings.requireUserPassword = data.require_password_to_approve;
    state.settings.removeApprovalsOnPush = !data.retain_approvals_on_push;
    state.isLoading = false;
  },
  [types.RECEIVE_SETTINGS_ERROR](state) {
    state.isLoading = false;
  },
  [types.REQUEST_UPDATE_SETTINGS](state) {
    state.isLoading = true;
  },
  [types.UPDATE_SETTINGS_SUCCESS](state, data) {
    state.settings.preventAuthorApproval = !data.allow_author_approval;
    state.settings.requireUserPassword = data.require_password_to_approve;
    state.settings.removeApprovalsOnPush = !data.retain_approvals_on_push;
    state.isLoading = false;
  },
  [types.UPDATE_SETTINGS_ERROR](state) {
    state.isLoading = false;
  },
};
