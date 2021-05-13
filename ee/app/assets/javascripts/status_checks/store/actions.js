import axios from '~/lib/utils/axios_utils';
import {
  convertObjectPropsToCamelCase,
  convertObjectPropsToSnakeCase,
} from '~/lib/utils/common_utils';
import * as types from './mutation_types';

export const setSettings = ({ commit }, settings) => {
  commit(types.SET_SETTINGS, settings);
};

export const fetchStatusChecks = ({ commit, rootState }) => {
  const { statusChecksPath } = rootState.settings;

  commit(types.SET_LOADING, true);

  return axios.get(statusChecksPath).then(({ data }) => {
    commit(types.SET_STATUS_CHECKS, convertObjectPropsToCamelCase(data, { deep: true }));
    commit(types.SET_LOADING, false);
  });
};

export const putStatusCheck = ({ dispatch, rootState }, statusCheck) => {
  const { statusChecksPath } = rootState.settings;

  return axios
    .put(
      `${statusChecksPath}/${statusCheck.id}`,
      convertObjectPropsToSnakeCase(statusCheck, { deep: true }),
    )
    .then(() => dispatch('fetchStatusChecks'));
};

export const postStatusCheck = ({ dispatch, rootState }, statusCheck) => {
  const { statusChecksPath } = rootState.settings;

  return axios
    .post(statusChecksPath, convertObjectPropsToSnakeCase(statusCheck, { deep: true }))
    .then(() => dispatch('fetchStatusChecks'));
};
