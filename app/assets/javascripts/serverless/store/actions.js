import * as types from './mutation_types';
import axios from '~/lib/utils/axios_utils';
import statusCodes from '~/lib/utils/http_status';
import { backOff } from '~/lib/utils/common_utils';
import createFlash from '~/flash';
import { MAX_REQUESTS } from '../constants';

export default {
  requestFunctionsLoading: ({ commit }) => commit(types.REQUEST_FUNCTIONS_LOADING),
  receiveFunctionsSuccess: ({ commit }, data) => commit(types.RECEIVE_FUNCTIONS_SUCCESS, data),
  receiveFunctionsNoDataSuccess: ({ commit }) => commit(types.RECEIVE_FUNCTIONS_NODATA_SUCCESS),
  receiveFunctionsError: ({ commit }, error) => commit(types.RECEIVE_FUNCTIONS_ERROR, error),

  receiveMetricsSuccess: ({ commit }, data) => commit(types.RECEIVE_METRICS_SUCCESS, data),
  receiveMetricsNoPrometheus: ({ commit }) => commit(types.RECEIVE_METRICS_NO_PROMETHEUS),
  receiveMetricsNoDataSuccess: ({ commit }, data) =>
    commit(types.RECEIVE_METRICS_NODATA_SUCCESS, data),
  receiveMetricsError: ({ commit }, error) => commit(types.RECEIVE_METRICS_ERROR, error),

  fetchFunctions: ({ dispatch }, { functionsPath }) => {
    let retryCount = 0;

    dispatch('requestFunctionsLoading');

    backOff((next, stop) => {
      axios
        .get(functionsPath)
        .then(response => {
          if (response.status === statusCodes.NO_CONTENT) {
            retryCount += 1;
            if (retryCount < MAX_REQUESTS) {
              next();
            } else {
              stop(null);
            }
          } else {
            stop(response.data);
          }
        })
        .catch(stop);
    })
      .then(data => {
        if (data !== null) {
          dispatch('receiveFunctionsSuccess', data);
        } else {
          dispatch('receiveFunctionsNoDataSuccess');
        }
      })
      .catch(error => {
        dispatch('receiveFunctionsError', error);
        createFlash(error);
      });
  },

  fetchMetrics: ({ dispatch }, { metricsPath, hasPrometheus }) => {
    let retryCount = 0;

    if (!hasPrometheus) {
      dispatch('receiveMetricsNoPrometheus');
      return;
    }

    backOff((next, stop) => {
      axios
        .get(metricsPath)
        .then(response => {
          if (response.status === statusCodes.NO_CONTENT) {
            retryCount += 1;
            if (retryCount < MAX_REQUESTS) {
              next();
            } else {
              dispatch('receiveMetricsNoDataSuccess');
              stop(null);
            }
          } else {
            stop(response.data);
          }
        })
        .catch(stop);
    })
      .then(data => {
        if (data === null) {
          return;
        }

        const updatedMetric = data.metrics;
        const queries = data.metrics.queries.map(query => ({
          ...query,
          result: query.result.map(result => ({
            ...result,
            values: result.values.map(([timestamp, value]) => ({
              time: new Date(timestamp * 1000).toISOString(),
              value: Number(value),
            })),
          })),
        }));

        updatedMetric.queries = queries;
        dispatch('receiveMetricsSuccess', updatedMetric);
      })
      .catch(error => {
        dispatch('receiveMetricsError', error);
        createFlash(error);
      });
  },
};
