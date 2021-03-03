import * as Sentry from '@sentry/browser';
import axios from '~/lib/utils/axios_utils';
import * as types from './mutation_types';

export const fetchSecurityConfiguration = ({ commit, state }) => {
  if (!state.securityConfigurationPath) {
    return commit(types.RECEIVE_SECURITY_CONFIGURATION_ERROR);
  }
  commit(types.REQUEST_SECURITY_CONFIGURATION);

  return axios({
    method: 'GET',
    url: state.securityConfigurationPath,
  })
    .then((response) => {
      const { data } = response;
      commit(types.RECEIVE_SECURITY_CONFIGURATION_SUCCESS, data);
    })
    .catch((error) => {
      Sentry.captureException(error);
      commit(types.RECEIVE_SECURITY_CONFIGURATION_ERROR);
    });
};
