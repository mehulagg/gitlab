import Tracking from '~/tracking';
import { getParameterValues } from '~/lib/utils/url_utility';
import * as types from './mutation_types';

export const setFilter = ({ commit }, filter) => {
  commit(types.SET_FILTER, filter);

  const [label, value] = Object.values(filter);
  Tracking.event(document.body.dataset.page, 'set_filter', { label, value });
};

export const setHideDismissedToggleInitialState = ({ commit }) => {
  const [urlParam] = getParameterValues('scope');
  const showDismissed = urlParam === 'all';
  commit(types.SET_TOGGLE_VALUE, { key: 'hideDismissed', value: !showDismissed });
};

export const setToggleValue = ({ commit }, { key, value }) => {
  commit(types.SET_TOGGLE_VALUE, { key, value });

  Tracking.event(document.body.dataset.page, 'set_toggle', {
    label: key,
    value,
  });
};
