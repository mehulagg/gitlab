import createFlash, { FLASH_TYPES } from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { joinPaths } from '~/lib/utils/url_utility';
import { s__, sprintf } from '~/locale';
import * as types from './mutation_types';

export const setEndpoints = ({ commit }, endpoints) => {
  commit(types.SET_ENDPOINT, endpoints.networkPoliciesEndpoint);
};

const commitPolicyError = (commit, type, payload) => {
  const error =
    payload?.error || s__('NetworkPolicies|Something went wrong, failed to update policy');
  commit(type, error);
  createFlash({
    message: error,
  });
};

export const createPolicy = ({ state, commit }, { environmentId, policy }) => {
  if (!state.policiesEndpoint || !environmentId || !policy) {
    return commitPolicyError(commit, types.RECEIVE_CREATE_POLICY_ERROR);
  }

  commit(types.REQUEST_CREATE_POLICY);

  return axios
    .post(state.policiesEndpoint, {
      environment_id: environmentId,
      manifest: policy.manifest,
    })
    .then(({ data }) => {
      commit(types.RECEIVE_CREATE_POLICY_SUCCESS, data);
      createFlash({
        message: sprintf(s__('NetworkPolicies|Policy %{policyName} was successfully changed'), {
          policyName: policy.name,
        }),

        type: FLASH_TYPES.SUCCESS,
      });
    })
    .catch((error) =>
      commitPolicyError(commit, types.RECEIVE_CREATE_POLICY_ERROR, error?.response?.data),
    );
};

export const updatePolicy = ({ state, commit }, { environmentId, policy }) => {
  if (!state.policiesEndpoint || !environmentId || !policy) {
    return commitPolicyError(commit, types.RECEIVE_UPDATE_POLICY_ERROR);
  }

  commit(types.REQUEST_UPDATE_POLICY);

  return axios
    .put(joinPaths(state.policiesEndpoint, policy.name), {
      environment_id: environmentId,
      manifest: policy.manifest,
      enabled: policy.isEnabled,
    })
    .then(({ data }) => {
      commit(types.RECEIVE_UPDATE_POLICY_SUCCESS, {
        policy,
        updatedPolicy: data,
      });
      createFlash({
        message: sprintf(s__('NetworkPolicies|Policy %{policyName} was successfully changed'), {
          policyName: policy.name,
        }),

        type: FLASH_TYPES.SUCCESS,
      });
    })
    .catch((error) =>
      commitPolicyError(commit, types.RECEIVE_UPDATE_POLICY_ERROR, error?.response?.data),
    );
};

export const deletePolicy = ({ state, commit }, { environmentId, policy }) => {
  if (!state.policiesEndpoint || !environmentId || !policy) {
    return commitPolicyError(commit, types.RECEIVE_DELETE_POLICY_ERROR);
  }

  commit(types.REQUEST_DELETE_POLICY);

  return axios
    .delete(joinPaths(state.policiesEndpoint, policy.name), {
      params: {
        environment_id: environmentId,
        manifest: policy.manifest,
      },
    })
    .then(() => {
      commit(types.RECEIVE_DELETE_POLICY_SUCCESS, {
        policy,
      });
    })
    .catch((error) =>
      commitPolicyError(commit, types.RECEIVE_DELETE_POLICY_ERROR, error?.response?.data),
    );
};
