import { getProjectValueStreamData, getProjectValueStreams } from '~/api/analytics_api';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import { DEFAULT_DAYS_TO_DISPLAY } from '../constants';
import * as types from './mutation_types';

export const setSelectedValueStream = ({ commit, dispatch }, valueStream) => {
  commit(types.SET_SELECTED_VALUE_STREAM, valueStream);
  return dispatch('fetchValueStreamData');
};

export const fetchValueStreamData = ({ commit, dispatch, getters, state }) => {
  const { requestPath, selectedValueStream } = state;
  commit(types.REQUEST_VALUE_STREAMS);

  return getProjectValueStreamData(requestPath, selectedValueStream.id)
    .then(({ data }) => dispatch('receiveValueStreamDataSuccess', data))
    .catch((error) => {
      const {
        response: { status },
      } = error;
      commit(types.RECEIVE_VALUE_STREAM_DATA_ERROR, status);
      throw error;
    });
};

export const receiveValueStreamsSuccess = (
  { state: { selectedValueStream = null }, commit, dispatch },
  data = [],
) => {
  commit(types.RECEIVE_VALUE_STREAMS_SUCCESS, data);

  if (!selectedValueStream && data.length) {
    const [firstStream] = data;
    return dispatch('setSelectedValueStream', firstStream);
  }

  return Promise.resolve();
  // .then(() => dispatch(types.FETCH_VALUE_STREAM_DATA))
};

// TODO: add getters for common request params
// TODO: calculate date range from that
export const fetchValueStreams = ({ commit, dispatch, state }) => {
  const { requestPath } = state;
  commit(types.REQUEST_VALUE_STREAMS);

  return getProjectValueStreams(requestPath)
    .then(({ data }) => dispatch('receiveValueStreamsSuccess', data))
    .catch((error) => {
      const {
        response: { status },
      } = error;
      commit(types.RECEIVE_VALUE_STREAMS_ERROR, status);
      throw error;
    });
};

export const fetchCycleAnalyticsData = ({
  state: { requestPath, startDate },
  dispatch,
  commit,
}) => {
  commit(types.REQUEST_CYCLE_ANALYTICS_DATA);

  return axios
    .get(requestPath, {
      params: { 'cycle_analytics[start_date]': startDate },
    })
    .then(({ data }) => commit(types.RECEIVE_CYCLE_ANALYTICS_DATA_SUCCESS, data))
    .then(() => dispatch('setSelectedStage'))
    .then(() => dispatch('fetchStageData'))
    .catch(() => {
      commit(types.RECEIVE_CYCLE_ANALYTICS_DATA_ERROR);
      createFlash({
        message: __('There was an error while fetching value stream analytics data.'),
      });
    });
};

export const fetchStageData = ({ state: { requestPath, selectedStage, startDate }, commit }) => {
  commit(types.REQUEST_STAGE_DATA);

  return axios
    .get(`${requestPath}/events/${selectedStage.name}.json`, {
      params: { 'cycle_analytics[start_date]': startDate },
    })
    .then(({ data }) => commit(types.RECEIVE_STAGE_DATA_SUCCESS, data))
    .catch(() => commit(types.RECEIVE_STAGE_DATA_ERROR));
};

export const setSelectedStage = ({ commit, state: { stages } }, selectedStage = null) => {
  const stage = selectedStage || stages[0];
  commit(types.SET_SELECTED_STAGE, stage);
};

export const setDateRange = ({ commit }, { startDate = DEFAULT_DAYS_TO_DISPLAY }) =>
  commit(types.SET_DATE_RANGE, { startDate });

export const initializeVsa = ({ commit, dispatch }, initialData = {}) => {
  commit(types.INITIALIZE_VSA, initialData);
  dispatch('fetchValueStreams');
  return dispatch('fetchCycleAnalyticsData');
};
