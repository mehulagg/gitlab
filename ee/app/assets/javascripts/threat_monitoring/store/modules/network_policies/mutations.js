import * as types from './mutation_types';

export default {
  [types.SET_ENDPOINT](state, endpoint) {
    state.policiesEndpoint = endpoint;
  },
  [types.REQUEST_CREATE_POLICY](state) {
    state.isUpdatingPolicy = true;
    state.errorUpdatingPolicy = false;
  },
  [types.RECEIVE_CREATE_POLICY_SUCCESS](state) {
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
  [types.RECEIVE_UPDATE_POLICY_SUCCESS](state) {
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
  [types.RECEIVE_DELETE_POLICY_SUCCESS](state) {
    state.isRemovingPolicy = false;
    state.errorRemovingPolicy = false;
  },
  [types.RECEIVE_DELETE_POLICY_ERROR](state) {
    state.isRemovingPolicy = false;
    state.errorRemovingPolicy = true;
  },
};
