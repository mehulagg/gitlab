import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import * as types from './mutation_types';

const setPolicies = (state, policies) => {
  state.policies = policies.map((policy) => convertObjectPropsToCamelCase(policy));
};

export default {
  [types.SET_ENDPOINT](state, endpoint) {
    state.policiesEndpoint = endpoint;
  },
  [types.REQUEST_POLICIES](state) {
    state.isLoadingPolicies = true;
    state.errorLoadingPolicies = false;
  },
  [types.RECEIVE_POLICIES_SUCCESS](state, policies) {
    setPolicies(state, policies);
    state.isLoadingPolicies = false;
    state.errorLoadingPolicies = false;
  },
  [types.RECEIVE_POLICIES_ERROR](state, policies = []) {
    setPolicies(state, policies);
    state.isLoadingPolicies = false;
    state.errorLoadingPolicies = true;
  },
  [types.REQUEST_CREATE_POLICY](state) {
    state.isUpdatingPolicy = true;
    state.errorUpdatingPolicy = false;
  },
  [types.RECEIVE_CREATE_POLICY_SUCCESS](state, policy) {
    const newPolicy = convertObjectPropsToCamelCase(policy);
    state.policies = [...state.policies, newPolicy];
    state.isUpdatingPolicy = false;
    state.errorUpdatingPolicy = false;
  },
  [types.RECEIVE_CREATE_POLICY_ERROR](state) {
    state.isUpdatingPolicy = false;
    state.errorUpdatingPolicy = true;
  },
  [types.REQUEST_UPDATE_POLICY](state) {
    state.isUpdatingPolicy = true;
    state.errorUpdatingPolicy = false;
  },
  [types.RECEIVE_UPDATE_POLICY_SUCCESS](state, { policy, updatedPolicy }) {
    const newPolicy = convertObjectPropsToCamelCase(updatedPolicy);
    state.policies = state.policies.map((pol) => (pol.name === policy.name ? newPolicy : pol));
    state.isUpdatingPolicy = false;
    state.errorUpdatingPolicy = false;
  },
  [types.RECEIVE_UPDATE_POLICY_ERROR](state) {
    state.isUpdatingPolicy = false;
    state.errorUpdatingPolicy = true;
  },
  [types.REQUEST_DELETE_POLICY](state) {
    state.isRemovingPolicy = true;
    state.errorRemovingPolicy = false;
  },
  [types.RECEIVE_DELETE_POLICY_SUCCESS](state, { policy }) {
    state.policies = state.policies.filter(({ name }) => name !== policy.name);
    state.isRemovingPolicy = false;
    state.errorRemovingPolicy = false;
  },
  [types.RECEIVE_DELETE_POLICY_ERROR](state) {
    state.isRemovingPolicy = false;
    state.errorRemovingPolicy = true;
  },
};
