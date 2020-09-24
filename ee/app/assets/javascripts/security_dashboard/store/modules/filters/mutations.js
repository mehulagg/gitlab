import * as types from './mutation_types';
import { ALL } from './constants';
import { setFilter } from './utils';

export default {
  [types.SET_ALL_FILTERS](state, payload = {}) {
    state.filters = state.filters.map(filter => {
      // If the payload is empty, we fall back to an empty selection
      const selectedOptions = (payload && payload[filter.id]) || [];

      const selection = Array.isArray(selectedOptions)
        ? new Set(selectedOptions)
        : new Set([selectedOptions]);

      // This prevents us from selecting nothing at all
      if (selection.size === 0) {
        selection.add(ALL);
      }

      return { ...filter, selection };
    });
    state.hideDismissed = payload.scope !== 'all';
  },
  [types.SET_FILTER](state, payload) {
    state.filters = setFilter(state.filters, payload);
  },
  [types.SET_FILTER_OPTIONS](state, payload) {
    const { filterId, options } = payload;
    state.filters.find(filter => filter.id === filterId).options = options;
  },
  [types.HIDE_FILTER](state, { filterId }) {
    const hiddenFilter = state.filters.find(({ id }) => id === filterId);
    if (hiddenFilter) {
      hiddenFilter.hidden = true;
    }
  },
  [types.SET_TOGGLE_VALUE](state, { key, value }) {
    state[key] = value;
  },
};
