import { overEvery } from 'lodash';
import { REPORT_TYPES, REPORT_TYPE_LIST } from './constants';

/**
 * Check if the given report is of a type that can be rendered (i.e, is mapped to a component and can be rendered)
 *
 * @param {{ type: string }} reportItem
 * @returns boolean
 */
const isSupportedType = ({ type }) => REPORT_TYPES.includes(type);

/**
 * Check if the given report is of type list
 *
 * @param {{ type: string } } reportItem
 * @returns boolean
 */
export const isListType = ({ type }) => type === REPORT_TYPE_LIST;

/**
 * Check if the current report item is of that list and is not nested deeper than the maximum depth
 *
 * @param {number} maxDepth
 * @returns {function}
 */
const isNotListTypeDeeperThan = (maxDepth) => (item, currentDepth) => {
  return !isListType(item) || maxDepth > currentDepth + 1;
};

/**
 * Takes an array of report items and recursively filters out items not matching the given condition
 *
 * @param {array} items
 * @param {{condition: function, currentDepth? : number }} options
 * @returns {array}
 */
const deepFilterListItems = (items, { condition, currentDepth = 0 }) =>
  items.reduce((filteredItems, currentItem) => {
    const shouldInsertItem = condition(currentItem, currentDepth);

    if (!shouldInsertItem) {
      return filteredItems;
    }

    const nextItem = { ...currentItem };

    if (isListType(nextItem)) {
      nextItem.items = deepFilterListItems(currentItem.items, {
        condition,
        currentDepth: currentDepth + 1,
      });
    }

    return [...filteredItems, nextItem];
  }, []);

/**
 * If the given entry is a list it will deep filter it's child items based on the given condition
 *
 * @param {function} condition
 * @returns {{*}}
 */
const filterNestedListsItems = (condition) => ([label, reportItem]) => {
  const filtered = isListType(reportItem)
    ? {
        ...reportItem,
        items: deepFilterListItems(reportItem.items, { condition }),
      }
    : reportItem;

  return [label, filtered];
};

/**
 * Takes a vulnerabilities details object - containing generic report data
 * Returns a copy of the report data with the following items being filtered:
 *
 * 1.) Report items which have a type that is not supported for rendering
 * 2.) Nested list items, which are nested beyond the given maximum depth
 *
 * @param {object} entries
 * @param {{ maxDepth?: number }} options
 * @returns {object}
 */
export const filterTypesAndLimitListDepth = (data, { maxDepth = 5 } = {}) => {
  const entries = Object.entries(data);
  const filterCriteria = overEvery([isSupportedType, isNotListTypeDeeperThan(maxDepth)]);

  const filteredEntries = entries
    .filter(([, reportItem]) => isSupportedType(reportItem))
    .map(filterNestedListsItems(filterCriteria));

  return Object.fromEntries(filteredEntries);
};
