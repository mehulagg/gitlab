import * as types from './mutation_types';
import createState from './state';

export default transformFunc => ({
  [types.SET_ENDPOINT](state, endpoint) {
    state.statisticsEndpoint = endpoint;
  },
  [types.REQUEST_STATISTICS](state, timeRange) {
    state.isLoadingStatistics = true;
    state.errorLoadingStatistics = false;
    state.timeRange = timeRange;
  },
  [types.RECEIVE_STATISTICS_SUCCESS](state, payload) {
    const stats = payload ? transformFunc(payload) : createState().statistics;
    state.statistics = stats;
    state.isLoadingStatistics = false;
    state.errorLoadingStatistics = false;
  },
  [types.RECEIVE_STATISTICS_ERROR](state) {
    state.isLoadingStatistics = false;
    state.errorLoadingStatistics = true;
  },
});
