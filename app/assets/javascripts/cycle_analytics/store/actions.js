import {
  getProjectValueStreamStages,
  getProjectValueStreams,
  getProjectValueStreamStageData,
  getProjectValueStreamMetrics,
  getValueStreamStageMedian,
} from '~/api/analytics_api';
import createFlash from '~/flash';
import { __ } from '~/locale';
import { DEFAULT_DAYS_TO_DISPLAY, DEFAULT_VALUE_STREAM } from '../constants';
import * as types from './mutation_types';

export const setSelectedValueStream = ({ commit, dispatch }, valueStream) => {
  commit(types.SET_SELECTED_VALUE_STREAM, valueStream);
  return dispatch('fetchValueStreamStages');
};

export const fetchValueStreamStages = ({ commit, state }) => {
  const { fullPath, selectedValueStream } = state;
  commit(types.REQUEST_VALUE_STREAM_STAGES);

  return getProjectValueStreamStages(fullPath, selectedValueStream.id)
    .then(({ data }) => commit(types.RECEIVE_VALUE_STREAM_STAGES_SUCCESS, data))
    .catch(({ response: { status } }) => {
      commit(types.RECEIVE_VALUE_STREAM_STAGES_ERROR, status);
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

export const fetchValueStreams = ({ commit, dispatch, state }) => {
  const { fullPath } = state;
  commit(types.REQUEST_VALUE_STREAMS);

  return getProjectValueStreams(fullPath)
    .then(({ data }) => dispatch('receiveValueStreamsSuccess', data))
    .then(() => Promise.all([dispatch('setSelectedStage'), dispatch('fetchStageMedians')]))
    .catch(({ response: { status } }) => {
      commit(types.RECEIVE_VALUE_STREAMS_ERROR, status);
    });
};

export const fetchCycleAnalyticsData = ({ state: { requestPath, startDate }, commit }) => {
  commit(types.REQUEST_CYCLE_ANALYTICS_DATA);

  return getProjectValueStreamMetrics(requestPath, { 'cycle_analytics[start_date]': startDate })
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

  return getProjectValueStreamStageData({
    requestPath,
    stageId: selectedStage.id,
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

const getStageMedians = ({ stageId, vsaParams, queryParams = {} }) => {
  console.log('getStageMedians', stageId, vsaParams, queryParams);
  return getValueStreamStageMedian({ ...vsaParams, stageId }, queryParams)
    .then(({ data }) => ({ stageId, value: data?.value || null }))
    .catch((err) => ({ stageId, value: null }));
};

export const fetchStageMedians = ({
  state: { stages },
  getters: { requestParams: vsaParams, queryParams },
  commit,
}) => {
  commit(types.REQUEST_STAGE_MEDIANS);
  console.log('fetchStageMedians::stages', stages);
  console.log('fetchStageMedians::requestParams', vsaParams);
  return Promise.all(
    stages.map(({ id: stageId }) =>
      getStageMedians({
        vsaParams,
        stageId,
        queryParams,
      }),
    ),
  )
    .then((data) => commit(types.RECEIVE_STAGE_MEDIANS_SUCCESS, data))
    .catch((error) => commit(types.RECEIVE_STAGE_MEDIANS_ERROR, error));
};

export const setSelectedStage = ({ dispatch, commit, state: { stages } }, selectedStage = null) => {
  const stage = selectedStage || stages[0];
  commit(types.SET_SELECTED_STAGE, stage);
  return dispatch('fetchStageData');
};

const refetchData = (dispatch, commit) => {
  commit(types.SET_LOADING, true);
  return Promise.resolve()
    .then(() => dispatch('fetchValueStreams'))
    .then(() => dispatch('fetchCycleAnalyticsData'))
    .finally(() => commit(types.SET_LOADING, false));
};

export const setFilters = ({ dispatch, commit }) => refetchData(dispatch, commit);

export const setDateRange = ({ dispatch, commit }, { startDate = DEFAULT_DAYS_TO_DISPLAY }) => {
  commit(types.SET_DATE_RANGE, { startDate });
  return refetchData(dispatch, commit);
};

export const initializeVsa = ({ commit, dispatch }, initialData = {}) => {
  commit(types.INITIALIZE_VSA, initialData);
  return refetchData(dispatch, commit);
};
