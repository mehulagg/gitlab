import Tracking from '~/tracking';
import * as types from './mutation_types';

export const setFilter = ({ commit }, filter) => {
  commit(types.SET_FILTER, filter);

  const [label, value] = Object.values(filter);
  Tracking.event(document.body.dataset.page, 'set_filter', { label, value });
};

export const toggleHideDismissed = ({ commit }) => {
  commit(types.TOGGLE_HIDE_DISMISSED);
};
