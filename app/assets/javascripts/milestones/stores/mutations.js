import * as types from './mutation_types';
import { X_TOTAL_HEADER } from '../constants';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import httpStatusCodes from '~/lib/utils/http_status';

export default {
  [types.SET_PROJECT_ID](state, projectId) {
    state.projectId = projectId;
  },
  [types.SET_GROUP_ID](state, groupId) {
    state.groupId = groupId;
  },
  [types.SET_SELECTED_MILESTONES](state, selectedMilestones) {
    state.selectedMilestones = selectedMilestones;
  },
  [types.SET_QUERY](state, query) {
    state.query = query;
  },

  [types.REQUEST_START](state) {
    state.requestCount += 1;
  },
  [types.REQUEST_FINISH](state) {
    state.requestCount -= 1;
  },

  [types.RECEIVE_MILESTONES_SUCCESS](state, response) {
    state.matches.branches = {
      list: convertObjectPropsToCamelCase(response.data).map(b => ({
        name: b.name,
        default: b.default,
      })),
      totalCount: parseInt(response.headers[X_TOTAL_HEADER], 10),
      error: null,
    };
  },
  [types.RECEIVE_MILESTONES_ERROR](state, error) {
    state.matches.branches = {
      list: [],
      totalCount: 0,
      error,
    };
  },
};
