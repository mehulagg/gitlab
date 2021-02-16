import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
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

export const updateSettings = ({ commit, state }, endpoint) => {
  const payload = {
    allow_author_approval: !state.settings.preventAuthorApproval,
  };

  commit(types.REQUEST_UPDATE_SETTINGS);

  return axios
    .put(endpoint, payload)
    .then(({ data }) => {
      commit(types.UPDATE_SETTINGS_SUCCESS, data);
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
