import createFlash from '~/flash';
import httpStatusCodes from '~/lib/utils/http_status';
import pollUntilComplete from '~/lib/utils/poll_until_complete';
import { s__ } from '~/locale';
import { getTimeWindowParams } from '../../utils';
import * as types from './mutation_types';

export const requestStatistics = ({ commit }, timeWindowParams) => {
  commit(types.REQUEST_STATISTICS, timeWindowParams);
};

export const receiveStatisticsSuccess = ({ commit }, statistics) =>
  commit(types.RECEIVE_STATISTICS_SUCCESS, statistics);
export const receiveStatisticsError = ({ commit }) => {
  commit(types.RECEIVE_STATISTICS_ERROR);
  createFlash({
    message: s__('ThreatMonitoring|Something went wrong, unable to fetch statistics'),
  });
};

export const fetchStatistics = ({ state, dispatch, rootState }) => {
  const { currentEnvironmentId, currentTimeWindow } = rootState.threatMonitoring;

  if (!state.statisticsEndpoint) {
    return dispatch('receiveStatisticsError');
  }

  const timeWindowParams = getTimeWindowParams(currentTimeWindow, Date.now());
  dispatch('requestStatistics', timeWindowParams);

  return pollUntilComplete(state.statisticsEndpoint, {
    params: {
      environment_id: currentEnvironmentId,
      ...timeWindowParams,
    },
  })
    .then(({ data }) => dispatch('receiveStatisticsSuccess', data))
    .catch((error) => {
      // A NOT_FOUND response from the endpoint means that there is no data for
      // the given parameters. There are various reasons *why* there could be
      // no data, but we can't distinguish between them, yet. So, just render
      // no data.
      if (error.response.status === httpStatusCodes.NOT_FOUND) {
        dispatch('receiveStatisticsSuccess', null);
      } else {
        dispatch('receiveStatisticsError');
      }
    });
};
