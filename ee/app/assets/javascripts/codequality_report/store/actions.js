import axios from '~/lib/utils/axios_utils';
import * as types from './mutation_types';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { s__ } from '~/locale';

import { parseCodeclimateMetrics } from '~/reports/codequality_report/store/utils/codequality_comparison';

export const setPage = ({ commit }, page) => commit(types.SET_PAGE, page);

export const requestReport = ({ commit }) => commit(types.REQUEST_REPORT);
export const receiveReportSuccess = ({ state, commit }, data) => {
  const parsedIssues = parseCodeclimateMetrics(data, state.blobPath);
  commit(types.RECEIVE_REPORT_SUCCESS, parsedIssues);
};
export const receiveReportError = ({ commit }, error) => commit(types.RECEIVE_REPORT_ERROR, error);

export const fetchReport = ({ state, dispatch }) => {
  dispatch('requestReport');

  axios
    .get(state.endpoint)
    .then(({ data }) => {
      if (!state.blobPath) throw new Error();
      dispatch('receiveReportSuccess', data);
    })
    .catch(error => {
      dispatch('receiveReportError', error);
      createFlash(s__('ciReport|There was an error fetching the codequality report.'));
    });
};
