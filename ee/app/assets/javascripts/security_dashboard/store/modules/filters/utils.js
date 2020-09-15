import { difference } from 'lodash';
import { isSubset } from '~/lib/utils/set';
import { ALL } from './constants';

export const isBaseFilterOption = id => id === ALL;
export const convertToArray = value => (Array.isArray(value) ? value : [value]);

/**
 * Returns whether or not the given state filter has a valid selection,
 * considering its available options.
 * @param {Object} filter The filter from the state to check.
 * @returns boolean
 */
export const hasValidSelection = ({ selection, options }) =>
  isSubset(selection, new Set(options.map(({ id }) => id)));

/**
 * Creates the selection object that is compatible with GraphQL
 * @param {Set} selection the set of selection strings
 * Example: ['sast-GitLab', 'dependency_scanning-GitLab', 'sast-Custom Scanner']
 * @returns {Object} the GraphQL compatible selection
 * Example:
 * {
 *    reportType: ['sast', 'dependency_scanning'],
 *    scanner: ['brakeman', 'geosec', 'gemnasium', 'custom_scanner_sast']
 * }
 */
export const createScannerSelection = (selection, options) =>
  [...selection].reduce(
    (acc, curr) => {
      if (curr === 'all') {
        return acc;
      }

      const currOption = options.find(option => option.id === curr);
      const { reportType, scanners } = currOption;

      acc.reportType.push(reportType);
      if (scanners.length) {
        acc.scanner.push(...scanners);
      }
      return acc;
    },
    { reportType: [], scanner: [] },
  );

/**
 * Recreates the scanner filter selection from the URL
 * @param {Array} options all the scanner filter options
 * @param {String|Array|} reportType the reportTypes parsed from the URL
 * @param {Array} scanners the scanners parsed from the URL
 * @returns {Set} the collection of ids of selected scanner filters
 */
export const rehydrateScannerSelection = (options, reportType, scanner) => {
  const reportTypes = convertToArray(reportType);
  const scanners = scanner ? convertToArray(scanner) : [];
  let updatedScanner = [...scanners];

  const idSelection = reportTypes.reduce((acc, curr) => {
    // Find all the filters with the given reportType in the URL
    const filteredOptions = options.filter(option => option.reportType === curr);
    filteredOptions.forEach(option => {
      // Find the filters with the given scanners in the URL and add them to the set
      // This is broken because this runs before the dynamic filters are retrieved and because
      // I do no know why I added filteredOptions.length === 1, but it seems like a good safeguard
      if (
        filteredOptions.length === 1 ||
        (Boolean(option.scanners.length) && scanners.some(val => option.scanners.includes(val)))
      ) {
        acc.add(option.id);
        updatedScanner = difference(updatedScanner, option.scanners);
      }
    });
    return acc;
  }, new Set());

  return {
    idSelection,
    selection: {
      reportType: reportTypes,
      scanner: scanners,
    },
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
export const setFilter = (filters, { optionId, filterId }) =>
  filters.map(filter => {
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
