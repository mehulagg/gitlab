import axios from '~/lib/utils/axios_utils';
import * as types from './mutation_types';
import { parseAccessibilityReport, compareAccessibilityReports } from './utils';

export const setBaseEndpoint = ({ commit }, endpoint) => commit(types.SET_BASE_ENDPOINT, endpoint);
export const setHeadEndpoint = ({ commit }, endpoint) => commit(types.SET_HEAD_ENDPOINT, endpoint);

export const fetchReport = ({ state, dispatch, commit }) => {
  commit(types.REQUEST_REPORT);

  Promise.all([
    axios.get(state.baseEndpoint).then(response => ({
      ...response.data,
      isHead: false,
    })),
    axios.get(state.headEndpoint).then(response => ({
      ...response.data,
      isHead: true,
    })),
  ])
    .then(responses => dispatch('receiveReportSuccess', responses))
    .catch(() => commit(types.RECEIVE_REPORT_ERROR));
};

export const receiveReportSuccess = ({ commit }, responses) => {
  const parsedReports = responses.map(response => ({
    isHead: response.isHead,
    issues: parseAccessibilityReport(response),
  }));
  const report = compareAccessibilityReports(parsedReports);
  commit(types.RECEIVE_REPORT_SUCCESS, report);
};

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
