import * as types from './mutation_types';

export default {
  [types.REQUEST_SETTINGS](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_SETTINGS_SUCCESS](state, data) {
    state.settings.preventAuthorApproval = !data.allow_author_approval;
    state.settings.preventMrApprovalRuleEdit = !data.allow_overrides_to_approver_list_per_merge_request;
    state.settings.requireUserPassword = data.require_password_to_approve;
    state.settings.removeApprovalsOnPush = !data.retain_approvals_on_push;
    state.settings.preventCommittersApproval = !data.allow_committer_approval;
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
    state.settings.preventMrApprovalRuleEdit = !data.allow_overrides_to_approver_list_per_merge_request;
    state.settings.requireUserPassword = data.require_password_to_approve;
    state.settings.removeApprovalsOnPush = !data.retain_approvals_on_push;
    state.settings.preventCommittersApproval = !data.allow_committer_approval;
    state.isLoading = false;
  },
  [types.UPDATE_SETTINGS_ERROR](state) {
    state.isLoading = false;
  },
};
