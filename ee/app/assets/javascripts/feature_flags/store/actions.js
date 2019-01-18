import * as types from './mutation_types';
import axios from '~/lib/utils/axios_utils';

export const requestFeatureFlags = ({ commit }) => commit(types.REQUEST_FEATURE_FLAGS);
export const receiveFeatureFlagsSuccess = ({ commit }, response) =>
  commit(types.RECEIVE_FEATURE_FLAGS_SUCCESS, response);
export const receiveFeatureFlagsError = ({ commit }, error) =>
  commit(types.RECEIVE_FEATURE_FLAGS_ERROR, error);

export const fetchFeatureFlags = ({ state, dispatch }) => {
  dispatch('requestFeatureFlags');

  axios
    .get(state.endpoint, {
      params: state.options,
    })
    .then(response => dispatch('receiveFeatureFlagsSuccess', response))
    .catch(error => dispatch('receiveFeatureFlagsError', error));
};

export const setFeatureFlagsEndpoint = ({ commit }, endpoint) =>
  commit(types.SET_FEATURE_FLAGS_ENDPOINT, endpoint);

export const setFeatureFlagsOptions = ({ commit }, options) =>
  commit(types.SET_FEATURE_FLAGS_OPTIONS, options);

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
