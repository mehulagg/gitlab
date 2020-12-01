import { SET_FILTER, SET_HIDE_DISMISSED } from './mutation_types';

export default {
  [SET_FILTER](state, filter) {
    state.filters = { ...state.filters, ...filter };
  },
  [SET_HIDE_DISMISSED](state, scope) {
    state.filters = { ...state.filters, scope };
  },
};
