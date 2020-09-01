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
 * @param {Array} filter the filter to mutate
 * @param {Object} option the selected option
 * @returns {Array} the mutated filters array
 */
export const setReportTypeAndScannerFilter = (filter, option) => {
  const { selection } = filter;

  const newSelection = {};
  Object.keys(selection).forEach(key => {
    const sel = selection[key];
    if (key === 'reportType') {
      const { id: optionId } = option;
      if (optionId === ALL) {
        sel.clear();
      } else if (sel.has(optionId)) {
        sel.delete(optionId);
      } else {
        sel.delete(ALL);
        sel.add(optionId);
      }

      if (sel.size === 0) {
        sel.add(ALL);
      }
      newSelection[key] = sel;
    } else {
      const { scanners: optionId } = option;
      if (optionId.length) {
        if (optionId.every(Set.prototype.has, selection[key])) {
          optionId.forEach(Set.prototype.delete, selection[key]);
        } else {
          selection[key].delete(ALL);
          optionId.forEach(Set.prototype.add, selection[key]);
        }

        if (selection[key].size === 0) {
          selection[key].add(ALL);
        }
        newSelection[key] = sel;
      }
    }
  });

  return {
    ...filter,
    selection,
  };
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
export const setFilter = (filters, { option, filterId }) =>
  filters.map(filter => {
    if (filter.id === filterId) {
      const { selection } = filter;
      const { id: optionId } = option;

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
