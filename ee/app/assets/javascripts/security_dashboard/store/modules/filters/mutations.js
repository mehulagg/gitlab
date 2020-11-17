import { mapValues } from 'lodash';
import { convertObjectPropsToSnakeCase } from '~/lib/utils/common_utils';
import * as types from './mutation_types';
import { DISMISSAL_STATES } from './constants';
import Tracking from '~/tracking';

export default {
  [types.SET_FILTER](state, filter) {
    // Convert the filter key to snake case and the selected option IDs to lower case. The API
    // endpoint needs them to be in this format.
    const convertedFilter = mapValues(convertObjectPropsToSnakeCase(filter), array =>
      array.map(element => element.toLowerCase()),
    );

    state.filters = { ...state.filters, ...convertedFilter };

    const [label, value] = Object.values(filter);
    Tracking.event(document.body.dataset.page, 'set_filter', { label, value });
  },
  [types.TOGGLE_HIDE_DISMISSED](state) {
    const scope =
      state.filters.scope === DISMISSAL_STATES.DISMISSED
        ? DISMISSAL_STATES.ALL
        : DISMISSAL_STATES.DISMISSED;

    state.filters = { ...state.filters, scope };

    Tracking.event(document.body.dataset.page, 'set_toggle', { label: 'scope', value: scope });
  },
};
