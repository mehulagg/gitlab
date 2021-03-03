import { mapValues } from 'lodash';
import { convertObjectPropsToSnakeCase } from '~/lib/utils/common_utils';
import Tracking from '~/tracking';
import { DISMISSAL_STATES } from './constants';
import { SET_FILTER, SET_HIDE_DISMISSED } from './mutation_types';

export const setFilter = ({ commit }, filter) => {
  // Convert the filter key to snake case and the selected option IDs to lower case. The API
  // endpoint needs them to be in this format.
  const convertedFilter = mapValues(convertObjectPropsToSnakeCase(filter), (array) =>
    array.map((element) => element.toLowerCase()),
  );

  commit(SET_FILTER, convertedFilter);

  const [label, value] = Object.values(filter);
  Tracking.event(document.body.dataset.page, 'set_filter', { label, value });
};

export const setHideDismissed = ({ commit }, isHidden) => {
  const value = isHidden ? DISMISSAL_STATES.DISMISSED : DISMISSAL_STATES.ALL;
  commit(SET_HIDE_DISMISSED, value);

  Tracking.event(document.body.dataset.page, 'set_toggle', { label: 'scope', value });
};
