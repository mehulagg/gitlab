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
 * Check if the given report is of type list
 *
 * @param {{ type: string } } reportItem
 * @returns boolean
 */
export const isOfTypeList = isOfType(REPORT_TYPES.list);

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
const deepFilterListItems = ({ filterCondition, currentDepth = 0 }) => (items) =>
  items.reduce((filteredItems, currentItem) => {
    const shouldInsertItem = filterCondition(currentItem, currentDepth);

    if (!shouldInsertItem) {
      return filteredItems;
    }

    const nextItem = { ...currentItem };

    if (isOfTypeList(nextItem)) {
      nextItem.items = deepFilterListItems({
        filterCondition,
        currentDepth: currentDepth + 1,
      })(currentItem.items);
    }

    return [...filteredItems, nextItem];
  }, []);

const overEveryReportType = (reportType) => (...fns) => ([label, reportItem]) => {
  const newReportItem = isOfType(reportType)(reportItem)
    ? {
        ...reportItem,
        items: flow(fns)(reportItem.items),
      }
    : reportItem;

  return [label, newReportItem];
};

const overEveryNamedListItem = overEveryReportType(REPORT_TYPES.namedList);

/**
 * Takes an entry from the vulnerability's details object and removes unsupported
 * report types from `named-list` types
 *
 * @param {function} filterFn
 * @param {number} maxDepth
 * @returns
 */
const filterNestedListsItems = (...filterConditions) =>
  overEveryReportType(REPORT_TYPES.list)(
    deepFilterListItems({ filterCondition: overEvery(filterConditions) }),
  );

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

  const filteredEntries = entries
    .filter(([, reportItem]) => isSupportedType(reportItem))
    .map(
      flow([
        filterNestedListsItems(isSupportedType, isNotOfTypeListDeeperThan(maxDepth)),
        overEveryNamedListItem(filterTypesAndLimitListDepth, transformItemsIntoArray),
        ([label, item]) => {
          if (isOfType(REPORT_TYPES.table)(item)) {
            // header - add key
            // rows - transform into table object
            return [
              label,
              {
                ...item,
                fields: item.header.map((headerItem, index) => ({
                  ...headerItem,
                  key: `column_${index}`,
                })),
                items: item.rows.map((row) => {
                  const getCellEntry = (cell, index) => [`column_${index}`, cell];
                  return Object.fromEntries(row.map(getCellEntry));
                }),
              },
            ];
          }
          return [label, item];
        },
      ]),
    );

  return Object.fromEntries(filteredEntries);
};
