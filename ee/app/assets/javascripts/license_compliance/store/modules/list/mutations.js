import * as types from './mutation_types';
import { toLicenseObject } from '../../../utils/mappers';

export default {
  [types.SET_LICENSES_ENDPOINT](state, payload) {
    state.endpoint = payload;
  },
  [types.REQUEST_LICENSES](state) {
    state.isLoading = true;
    state.errorLoading = false;
  },
  [types.RECEIVE_LICENSES_SUCCESS](state, { licenses, reportInfo, pageInfo }) {
    state.licenses = licenses.map(toLicenseObject);
    state.pageInfo = pageInfo;
    state.isLoading = false;
    state.errorLoading = false;
    state.initialized = true;
    state.reportInfo = {
      status: reportInfo.status,
      jobPath: reportInfo.job_path,
      generatedAt: reportInfo.generated_at,
    };
  },
  [types.RECEIVE_LICENSES_ERROR](state) {
    state.isLoading = false;
    state.errorLoading = true;
    state.initialized = true;
  },
};
