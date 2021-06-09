import { getProjectValueStreamStages, getProjectValueStreams } from '~/api/analytics_api';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import { DEFAULT_DAYS_TO_DISPLAY, DEFAULT_VALUE_STREAM } from '../constants';
import * as types from './mutation_types';

export const setSelectedValueStream = ({ commit, dispatch }, valueStream) => {
  commit(types.SET_SELECTED_VALUE_STREAM, valueStream);
  return dispatch('fetchValueStreamStages');
};

export const fetchValueStreamStages = ({ commit, state }) => {
  const { fullPath, selectedValueStream } = state;
  commit(types.REQUEST_VALUE_STREAMS);

  return getProjectValueStreamStages(fullPath, selectedValueStream.id)
    .then(({ data }) => commit(types.RECEIVE_VALUE_STREAM_STAGES_SUCCESS, data))
    .catch((error) => {
      const {
        response: { status },
      } = error;
      commit(types.RECEIVE_VALUE_STREAM_STAGES_ERROR, status);
      throw error;
    });
};

export const receiveValueStreamsSuccess = ({ commit, dispatch }, data = []) => {
  commit(types.RECEIVE_VALUE_STREAMS_SUCCESS, data);
  if (data.length) {
    const [firstStream] = data;
    return dispatch('setSelectedValueStream', firstStream);
  }
  return dispatch('setSelectedValueStream', DEFAULT_VALUE_STREAM);
};

// TODO: add getters for common request params
// TODO: calculate date range from that
export const fetchValueStreams = ({ commit, dispatch, state }) => {
  const { fullPath } = state;
  commit(types.REQUEST_VALUE_STREAMS);

  return getProjectValueStreams(fullPath)
    .then(({ data }) => dispatch('receiveValueStreamsSuccess', data))
    .then(() => dispatch('setSelectedStage'))
    .catch((error) => {
      const {
        response: { status },
      } = error;
      commit(types.RECEIVE_VALUE_STREAMS_ERROR, status);
      throw error;
    });
};

export const fetchCycleAnalyticsData = ({ state: { requestPath, startDate }, commit }) => {
  commit(types.REQUEST_CYCLE_ANALYTICS_DATA);

  return axios
    .get(requestPath, {
      params: { 'cycle_analytics[start_date]': startDate },
    })
    .then(({ data }) => commit(types.RECEIVE_CYCLE_ANALYTICS_DATA_SUCCESS, data))
    .catch(() => {
      commit(types.RECEIVE_CYCLE_ANALYTICS_DATA_ERROR);
      createFlash({
        message: __('There was an error while fetching value stream summary data.'),
      });
    });
};

export const fetchStageData = ({ state: { requestPath, selectedStage, startDate }, commit }) => {
  commit(types.REQUEST_STAGE_DATA);

  // TODO: move to api
  return axios
    .get(`${requestPath}/events/${selectedStage.id}`, {
      params: { 'cycle_analytics[start_date]': startDate },
    })
    .then(({ data }) => {
      // when there's a query timeout, the request succeeds but the error is encoded in the response data
      if (data?.error) {
        commit(types.RECEIVE_STAGE_DATA_ERROR, data.error);
      } else {
        commit(types.RECEIVE_STAGE_DATA_SUCCESS, data);
      }
    })
    .catch(() => commit(types.RECEIVE_STAGE_DATA_ERROR));
};

export const setSelectedStage = ({ dispatch, commit, state: { stages } }, selectedStage = null) => {
  const stage = selectedStage || stages[0];
  commit(types.SET_SELECTED_STAGE, stage);
  return dispatch('fetchStageData');
};

export const setDateRange = ({ commit }, { startDate = DEFAULT_DAYS_TO_DISPLAY }) =>
  commit(types.SET_DATE_RANGE, { startDate });

export const initializeVsa = ({ commit, dispatch }, initialData = {}) => {
  commit(types.INITIALIZE_VSA, initialData);
  return Promise.all([dispatch('fetchCycleAnalyticsData'), dispatch('fetchValueStreams')]);
};
