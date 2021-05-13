import axios from '~/lib/utils/axios_utils';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import * as types from './mutation_types';

export const fetchStatusChecks = ({ commit }, { statusChecksPath }) => {
  commit(types.SET_LOADING, true);

  return axios.get(statusChecksPath).then(({ data }) => {
    commit(types.SET_STATUS_CHECKS, convertObjectPropsToCamelCase(data, { deep: true }));
    commit(types.SET_LOADING, false);
  });
};
