import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { s__ } from '~/locale';
import * as types from './types';

export const requestStatusChecks = ({ commit }) => {
  commit(types.SET_LOADING, true);
};

export const receiveStatusChecksSuccess = ({ commit }, approvalSettings) => {
  commit(types.SET_STATUS_CHECKS, approvalSettings);
  commit(types.SET_LOADING, false);
};

export const receiveStatusChecksError = () => {
  createFlash({
    message: s__('StatusCheck|An error occurred fetching the status checks.'),
  });
};

const fetchStatusChecks = ({ dispatch }, { statusChecksPath }) => {
  dispatch('requestStatusChecks');

  return axios
    .get(statusChecksPath)
    .then((res) => dispatch('receiveStatusChecksSuccess', res.data))
    .catch(() => dispatch('receiveStatusChecksError'));
};
