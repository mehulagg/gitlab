import * as types from './mutation_types';

const mapDataToState = (state, data) => {
  state.settings.preventAuthorApproval = !data.allow_author_approval;
  state.settings.preventMrApprovalRuleEdit = !data.allow_overrides_to_approver_list_per_merge_request;
  state.settings.requireUserPassword = data.require_password_to_approve;
  state.settings.removeApprovalsOnPush = !data.retain_approvals_on_push;
  state.settings.preventCommittersApproval = !data.allow_committer_approval;
  state.isLoading = false;

  return state;
};

export default {
  [types.REQUEST_SETTINGS](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_SETTINGS_SUCCESS](state, data) {
    mapDataToState(state, data);
  },
  [types.RECEIVE_SETTINGS_ERROR](state) {
    state.isLoading = false;
  },
  [types.REQUEST_UPDATE_SETTINGS](state) {
    state.isLoading = true;
  },
  [types.UPDATE_SETTINGS_SUCCESS](state, data) {
    mapDataToState(state, data);
  },
  [types.UPDATE_SETTINGS_ERROR](state) {
    state.isLoading = false;
  },
  [types.SET_SETTING_PREVENT_AUTHOR_APPROVAL](state, value) {
    state.settings.preventAuthorApproval = value;
  },
  [types.SET_SETTING_PREVENT_MR_APPROVAL_RULE_EDIT](state, value) {
    state.settings.preventMrApprovalRuleEdit = value;
  },
  [types.SET_SETTING_REQUIRE_USER_PASSWORD](state, value) {
    state.settings.requireUserPassword = value;
  },
  [types.SET_SETTING_REMOVE_APPROVALS_ON_PUSH](state, value) {
    state.settings.removeApprovalsOnPush = value;
  },
  [types.SET_SETTING_PREVENT_COMMITTERS_APPROVAL](state, value) {
    state.settings.preventCommittersApproval = value;
  },
};
