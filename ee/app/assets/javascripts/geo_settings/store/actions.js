import Api from 'ee/api';
import createFlash from '~/flash';
import { __ } from '~/locale';
import * as types from './mutation_types';

export const fetchGeoSettings = ({ commit }) => {
  commit(types.REQUEST_GEO_SETTINGS);
  Api.getApplicationSettings()
    .then(({ data }) => {
      commit(types.RECEIVE_GEO_SETTINGS_SUCCESS, {
        timeout: data.geo_status_timeout,
        allowedIp: data.geo_node_allowed_ips,
      });
    })
    .catch(() => {
      createFlash({
        message: __('There was an error fetching the Geo Settings'),
      });
      commit(types.RECEIVE_GEO_SETTINGS_ERROR);
    });
};

export const updateGeoSettings = ({ commit, state }) => {
  commit(types.REQUEST_UPDATE_GEO_SETTINGS);
  Api.updateApplicationSettings({
    geo_status_timeout: state.timeout,
    geo_node_allowed_ips: state.allowedIp,
  })
    .then(({ data }) => {
      commit(types.RECEIVE_UPDATE_GEO_SETTINGS_SUCCESS, {
        timeout: data.geo_status_timeout,
        allowedIp: data.geo_node_allowed_ips,
      });
    })
    .catch(() => {
      createFlash({
        message: __('There was an error updating the Geo Settings'),
      });
      commit(types.RECEIVE_UPDATE_GEO_SETTINGS_ERROR);
    });
};

export const setTimeout = ({ commit }, { timeout }) => {
  commit(types.SET_TIMEOUT, timeout);
};

export const setAllowedIp = ({ commit }, { allowedIp }) => {
  commit(types.SET_ALLOWED_IP, allowedIp);
};

export const setFormError = ({ commit }, { key, error }) => {
  commit(types.SET_FORM_ERROR, { key, error });
};
