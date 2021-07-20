import { overEvery, flow } from 'lodash';
import { REPORT_TYPES } from './constants';

/**
 * Check if the given report is of a type that can be rendered (i.e, is mapped to a component and can be rendered)
 *
 * @param {{ type: string }} reportItem
 * @returns boolean
 */
const isSupportedType = ({ type }) => Object.values(REPORT_TYPES).includes(type);

/**
 * Higher order function that accepts a type and returns a function that returns true if the passed in report type matches
 *
 * @param {*} typeToCheck
 * @returns
 */
const isOfType = (typeToCheck) => ({ type }) => type === typeToCheck;

/**
 * Check if the given report is of type 'list'
 *
 * @param {{ type: string } } reportItem
 * @returns boolean
 */
export const isOfTypeList = isOfType(REPORT_TYPES.list);

/**
 * Check if the given report is of type 'table'
 *
 * @param {{ type: string } } reportItem
 * @returns boolean
 */
const isOfTypeTable = isOfType(REPORT_TYPES.table);

/**
 * Check if the given report is of type named-list
 *
 * @param {{ type: string } } reportItem
 * @returns boolean
 */
export const isOfTypeNamedList = isOfType(REPORT_TYPES.namedList);

/**
 * Check if the current report item is of that list and is not nested deeper than the maximum depth
 *
 * @param {number} maxDepth
 * @returns {function}
 */
const isNotOfTypeListDeeperThan = (maxDepth) => (item, currentDepth) => {
  return !isOfTypeList(item) || maxDepth > currentDepth + 1;
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

    if (isOfTypeList(nextItem)) {
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
  const filtered = isOfTypeList(reportItem)
    ? {
        ...reportItem,
        items: deepFilterListItems(reportItem.items, { condition }),
      }
    : reportItem;

  return [label, filtered];
};

/**
 * Takes an entry from the vulnerability's details object and removes unsupported
 * report types from `named-list` types
 *
 * @param {function} filterFn
 * @param {number} maxDepth
 * @returns
 */
const overEveryNamedListItem = (fn) => ([label, reportItem]) => {
  const filtered = isOfTypeNamedList(reportItem)
    ? {
        ...reportItem,
        items: fn(reportItem.items),
      }
    : reportItem;

  return [label, filtered];
};

/**
 * Takes an object of the shape
 * {
 *  label1: { ... }
 *  label2: { ... }
 * }
 * and returns an array of the shape
 * [{ label: 'label1', ...  }, { label: 'label2', ...}]
 *
 * @param {*} items
 * @returns
 */
const transformItemsIntoArray = (items) => {
  return Object.entries(items).map(([label, value]) => ({ ...value, label }));
};

/**
 * Takes a report item's entry and transforms each item of type `table` in the following ways:
 *
 * 1. Adds a index-based key to each header-item (eg.: ` { key: column_0, ...headerData }`)
 * 2. Transforms each item within the `rows` array into an object where each item's key corresponds
 *    to it's header's key
 *    (e.g: `rows: [
 *      [{ column_0: {...cellData }}]
 *    ]`)
 *
 *  This prepares the data to be rendered into a table.
 *
 * @param [String, {*}] report entry
 * @returns [String, {*}]
 */
const transformTableItems = ([label, item]) => {
  const newItem = isOfTypeTable(item)
    ? {
        ...item,
        header: item.header.map((headerItem, index) => ({
          ...headerItem,
          key: `column_${index}`,
        })),
        rows: item.rows.map((row) => {
          const getCellEntry = (cell, index) => [`column_${index}`, cell];
          // transforms the array into an object with `column_N` as keys
          return Object.fromEntries(row.map(getCellEntry));
        }),
      }
    : item;

  return [label, newItem];
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
  const filterCriteria = overEvery([isSupportedType, isNotOfTypeListDeeperThan(maxDepth)]);

  const filteredEntries = entries
    .filter(([, reportItem]) => isSupportedType(reportItem))
    .map(
      flow([
        filterNestedListsItems(filterCriteria),
        overEveryNamedListItem(flow([filterTypesAndLimitListDepth, transformItemsIntoArray])),
        transformTableItems,
      ]),
    );

  return Object.fromEntries(filteredEntries);
};
