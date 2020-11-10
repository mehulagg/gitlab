import * as types from './mutation_types';

export default {
  [types.SET_FILTER](state, filter) {
    state.filters = { ...state.filters, ...filter };
  },
  [types.TOGGLE_HIDE_DISMISSED](state) {
    const scope = state.filters.scope === 'dismissed' ? 'all' : 'dismissed';
    state.filters = { ...state.filters, scope };
  },
};
