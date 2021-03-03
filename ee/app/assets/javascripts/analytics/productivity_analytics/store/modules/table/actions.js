import axios from '~/lib/utils/axios_utils';
import { parseIntPagination, normalizeHeaders } from '~/lib/utils/common_utils';
import { daysToMergeMetric } from '../../../constants';
import * as types from './mutation_types';

export const fetchMergeRequests = ({ dispatch, state, rootState, rootGetters }) => {
  dispatch('requestMergeRequests');

  const { sortField, sortOrder, pageInfo } = state;

  const params = {
    ...rootGetters['filters/getCommonFilterParams'](),
    days_to_merge: rootState.charts.charts.main.selected,
    sort: `${sortField}_${sortOrder}`,
    page: pageInfo ? pageInfo.page : null,
  };

  return axios
    .get(rootState.endpoint, { params })
    .then((response) => {
      const { headers, data } = response;
      dispatch('receiveMergeRequestsSuccess', { headers, data });
    })
    .catch((err) => dispatch('receiveMergeRequestsError', err));
};

export const requestMergeRequests = ({ commit }) => commit(types.REQUEST_MERGE_REQUESTS);

export const receiveMergeRequestsSuccess = ({ commit }, { headers, data: mergeRequests }) => {
  const normalizedHeaders = normalizeHeaders(headers);
  const pageInfo = parseIntPagination(normalizedHeaders);

  commit(types.RECEIVE_MERGE_REQUESTS_SUCCESS, { pageInfo, mergeRequests });
};

export const receiveMergeRequestsError = ({ commit }, { response }) => {
  const { status } = response;
  commit(types.RECEIVE_MERGE_REQUESTS_ERROR, status);
};

export const setSortField = ({ commit, dispatch }, data) => {
  commit(types.SET_SORT_FIELD, data);

  // let's make sure we update the column that we sort on (except for 'days_to_merge')
  if (data !== daysToMergeMetric.key) {
    dispatch('setColumnMetric', data);
  }

  dispatch('fetchMergeRequests');
};

export const toggleSortOrder = ({ commit, dispatch }) => {
  commit(types.TOGGLE_SORT_ORDER);

  dispatch('fetchMergeRequests');
};

export const setColumnMetric = ({ commit }, data) => commit(types.SET_COLUMN_METRIC, data);

export const setPage = ({ commit, dispatch }, data) => {
  commit(types.SET_PAGE, data);

  dispatch('fetchMergeRequests');
};
