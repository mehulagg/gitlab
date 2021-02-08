import { __ } from '~/locale';
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import * as types from './mutation_types';

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

export const updatePreventAuthorApproval = ({ commit }, preventAuthorApproval) => {
  commit(types.UPDATE_PREVENT_AUTHOR_APPROVAL, preventAuthorApproval);
};
