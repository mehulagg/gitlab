import * as types from './mutation_types';

export const setFilter = ({ commit }, filter) => {
  commit(types.SET_FILTER, filter);
};

export const toggleHideDismissed = ({ commit }) => {
  commit(types.TOGGLE_HIDE_DISMISSED);
};
