import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { __ } from '~/locale';
import {
  REQUEST_UNSCANNED_PROJECTS,
  RECEIVE_UNSCANNED_PROJECTS_SUCCESS,
  RECEIVE_UNSCANNED_PROJECTS_ERROR,
} from './mutation_types';

export const fetchUnscannedProjects = ({ dispatch }, endpoint) => {
  dispatch('requestUnscannedProjects');

  return axios
    .get(endpoint)
    .then(({ data }) => data.map(convertObjectPropsToCamelCase))
    .then((data) => {
      dispatch('receiveUnscannedProjectsSuccess', data);
    })
    .catch(() => {
      dispatch('receiveUnscannedProjectsError');
    });
};

export const requestUnscannedProjects = ({ commit }) => {
  commit(REQUEST_UNSCANNED_PROJECTS);
};

export const receiveUnscannedProjectsSuccess = ({ commit }, payload) => {
  commit(RECEIVE_UNSCANNED_PROJECTS_SUCCESS, payload);
};

export const receiveUnscannedProjectsError = ({ commit }) => {
  createFlash({
    message: __('Unable to fetch unscanned projects'),
  });

  commit(RECEIVE_UNSCANNED_PROJECTS_ERROR);
};
