import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import * as types from './mutation_types';

const mapStateToPayload = (state) => ({
  allow_author_approval: !state.settings.preventAuthorApproval,
  allow_overrides_to_approver_list_per_merge_request: !state.settings.preventMrApprovalRuleEdit,
  require_password_to_approve: state.settings.requireUserPassword,
  retain_approvals_on_push: !state.settings.removeApprovalsOnPush,
  allow_committer_approval: !state.settings.preventCommittersApproval,
});

export const fetchSettings = ({ commit }, endpoint) => {
  commit(types.REQUEST_SETTINGS);

  return axios
    .get(endpoint)
    .then(({ data }) => {
      commit(types.RECEIVE_SETTINGS_SUCCESS, data);
    })
    .catch(({ response }) => {
      const error = response?.data?.message;

      commit(types.RECEIVE_SETTINGS_ERROR, error);
      createFlash({
        message: __('There was an error loading merge request approval settings.'),
        captureError: true,
        error,
      });
    });
};

export const updateSettings = ({ commit, state }, endpoint) => {
  commit(types.REQUEST_UPDATE_SETTINGS);

  return axios
    .put(endpoint, { ...mapStateToPayload(state) })
    .then(({ data }) => {
      commit(types.UPDATE_SETTINGS_SUCCESS, data);
      createFlash({
        message: __('Merge request approval settings have been updated.'),
        type: 'notice',
      });
    })
    .catch(({ response }) => {
      const error = response?.data?.message;

      commit(types.UPDATE_SETTINGS_ERROR, error);
      createFlash({
        message: __('There was an error updating merge request approval settings.'),
        captureError: true,
        error,
      });
    });
};

export const setPreventAuthorApproval = ({ commit }, { preventAuthorApproval }) => {
  commit(types.SET_PREVENT_AUTHOR_APPROVAL, preventAuthorApproval);
};

export const setPreventCommittersApproval = ({ commit }, { preventCommittersApproval }) => {
  commit(types.SET_PREVENT_COMMITTERS_APPROVAL, preventCommittersApproval);
};

export const setPreventMrApprovalRuleEdit = ({ commit }, { preventMrApprovalRuleEdit }) => {
  commit(types.SET_PREVENT_MR_APPROVAL_RULE_EDIT, preventMrApprovalRuleEdit);
};

export const setRemoveApprovalsOnPush = ({ commit }, { removeApprovalsOnPush }) => {
  commit(types.SET_REMOVE_APPROVALS_ON_PUSH, removeApprovalsOnPush);
};

export const setRequireUserPassword = ({ commit }, { requireUserPassword }) => {
  commit(types.SET_REQUIRE_USER_PASSWORD, requireUserPassword);
};
