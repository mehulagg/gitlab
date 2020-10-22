import { isBaseFilterOption } from './utils';

/**
 * Loops through all the filters and returns all the active ones
 * stripping out base filter options.
 * @returns Object
 * e.g. { type: ['sast'], severity: ['high', 'medium'] }
 */
export const activeFilters = state => {
  const filters = state.filters.reduce((acc, filter) => {
    acc[filter.id] = [...Array.from(filter.selection)].filter(id => !isBaseFilterOption(id));
    return acc;
  }, {});
  // hide_dismissed is hardcoded as it currently is an edge-case, more info in the MR:
  // https://gitlab.com/gitlab-org/gitlab-ee/merge_requests/15333#note_208301144
  filters.scope = state.hideDismissed ? 'dismissed' : 'all';
  return filters;
};

export const visibleFilters = ({ filters }) => filters.filter(({ hidden }) => !hidden);
