import axios from '~/lib/utils/axios_utils';
import * as types from './mutation_types';

export const legacyFetchCycleAnalyticsData = (
  { state: { requestPath } },
  options = { startDate: 30 },
) => {
  const { startDate, projectIds } = options;

  return axios
    .get(requestPath, {
      params: {
        'cycle_analytics[start_date]': startDate,
        'cycle_analytics[project_ids]': projectIds,
      },
    })
    .then((x) => x.data);
};

export const legacyFetchStageData = ({ state: { requestPath } }, options) => {
  const { stage, startDate, projectIds } = options;

  return axios
    .get(`${requestPath}/events/${stage.name}.json`, {
      params: {
        'cycle_analytics[start_date]': startDate,
        'cycle_analytics[project_ids]': projectIds,
      },
    })
    .then((x) => x.data);
};

export const initialize = ({ commit }, initialData = {}) => commit(types.INITIALIZE, initialData);
