import { __ } from '~/locale';
import axios from '~/lib/utils/axios_utils';
import * as types from './mutation_types';
import createFlash from '~/flash';

export const fetchSetting = ({ commit }, endpoint) => {
  commit(types.REQUEST_SETTING);

  return axios
    .get(endpoint)
    .then(({ data }) => {
      commit(types.RECEIVE_SETTING_SUCCESS, data);
    })
    .catch((error) => {
      commit(types.RECEIVE_SETTING_ERROR, error);
      createFlash(__('There was an error loading merge request approval settings.'));
    });
};
