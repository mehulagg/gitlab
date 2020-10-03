import { isSubset } from '~/lib/utils/set';
import { ALL } from './constants';

export const isBaseFilterOption = id => id === ALL;

/**
 * Returns whether or not the given state filter has a valid selection,
 * considering its available options.
 * @param {Object} filter The filter from the state to check.
 * @returns boolean
 */
export const hasValidSelection = ({ selection, options }) =>
  isSubset(selection, new Set(options.map(({ id }) => id)));

/**
 * Takes a filter array and a selected payload.
 * It then either adds or removes that option from the appropriate selected filter.
 * With a few extra exceptions around the `ALL` special case.
 * @param {Array} filters the filters to mutate
 * @param {Object} payload
 * @param {String} payload.optionId the ID of the option that was just selected
 * @param {String} payload.filterId the ID of the filter that the selected option belongs to
 * @returns {Array} the mutated filters array
 */
export const setFilter = (filters, { optionId, filterId }) => {
  return filters.map(filter => {
    if (filter.id === filterId) {
      const { selection } = filter;

      if (optionId === ALL) {
        selection.clear();
      } else if (selection.has(optionId)) {
        selection.delete(optionId);
      } else {
        selection.delete(ALL);
        selection.add(optionId);
      }

      if (selection.size === 0) {
        selection.add(ALL);
      }

      return {
        ...filter,
        selection,
      };
    }
    return filter;
  });
};
