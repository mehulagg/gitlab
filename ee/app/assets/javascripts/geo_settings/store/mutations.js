import { DEFAULT_TIMEOUT, DEFAULT_ALLOWED_IP } from '../constants';
import * as types from './mutation_types';

export default {
  [types.REQUEST_GEO_SETTINGS](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_GEO_SETTINGS_SUCCESS](state, { timeout, allowedIp }) {
    state.isLoading = false;
    state.timeout = timeout;
    state.allowedIp = allowedIp;
  },
  [types.RECEIVE_GEO_SETTINGS_ERROR](state) {
    state.isLoading = false;
    state.timeout = DEFAULT_TIMEOUT;
    state.allowedIp = DEFAULT_ALLOWED_IP;
  },
  [types.REQUEST_UPDATE_GEO_SETTINGS](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_UPDATE_GEO_SETTINGS_SUCCESS](state, { timeout, allowedIp }) {
    state.isLoading = false;
    state.timeout = timeout;
    state.allowedIp = allowedIp;
  },
  [types.RECEIVE_UPDATE_GEO_SETTINGS_ERROR](state) {
    state.isLoading = false;
    state.timeout = DEFAULT_TIMEOUT;
    state.allowedIp = DEFAULT_ALLOWED_IP;
  },
  [types.SET_TIMEOUT](state, timeout) {
    state.timeout = timeout;
  },
  [types.SET_ALLOWED_IP](state, allowedIp) {
    state.allowedIp = allowedIp;
  },
  [types.SET_FORM_ERROR](state, { key, error }) {
    state.formErrors[key] = error;
  },
};
