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
 * Takes the filters and a selected payload.
 * It then either adds or removes that option from the appropriate linked filter.
 * With a few extra exceptions around the `ALL` special case.
 * @param {Array} filters the filters to mutate
 * @param {Object} payload
 * @param {String} payload.id the ID of the filter that needs to be modified
 * @param {String} payload.linkId the ID of the filter option who is being selected
 * @returns {Array} the mutated filters array
 */
const modifyLinkedFilter = (filters, { id: filterId, linkId }) => {
  const newFilters = filters.map(filter => {
    if (filter.id === filterId) {
      const { selection } = filter;

      const option = filter.options.find(curr => curr.linkId === linkId);
      const { id: optionId } = option;

      if (optionId.length) {
        if (optionId.every(Set.prototype.has, selection)) {
          optionId.forEach(Set.prototype.delete, selection);
        } else {
          selection.delete(ALL);
          optionId.forEach(Set.prototype.add, selection);
        }

        if (selection.size === 0) {
          selection.add(ALL);
        }
      }

      return {
        ...filter,
        selection,
      };
    }
    return filter;
  });

  return newFilters;
};

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
export const setFilter = (filters, { option, filterId }) => {
  let link;
  let newFilters = filters.map(filter => {
    if (filter.id === filterId) {
      const { selection } = filter;
      const { id: optionId } = option;

      if (optionId === ALL) {
        selection.clear();
      } else if (selection.has(optionId)) {
        selection.delete(optionId);
        if (option.link) {
          link = option.link;
        }
      } else {
        selection.delete(ALL);
        selection.add(optionId);
        if (option.link) {
          link = option.link;
        }
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

  if (link) {
    newFilters = modifyLinkedFilter(newFilters, link);
  }

  return newFilters;
};
