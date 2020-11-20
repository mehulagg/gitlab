/**
 * Sorts an array of objects by a given property name.
 * An optional `lastItemValue` ensures the item with the given value is always last.
 *
 * Example i: [{prop: 'c'}, {prop: 'e'}, {prop: 'a'}]
 * Example o: [{prop: 'a'}, {prop: 'c'}, {prop: 'e'}]
 *
 * @param {Array} objects
 * @param {String} prop
 * @param {String} lastItemValue
 * @returns {Array}
 */
export const sortObjectsBy = (objects, prop, lastItemValue) => {
  return objects.sort((a, b) => {
    const aVal = a[prop];
    const bVal = b[prop];

    // 'lastItemValue' sort after anything else
    const aIsLast = aVal === lastItemValue;
    const bIsLast = bVal === lastItemValue;

    const order = { neutral: 0, before: -1, after: 1 };

    if (aIsLast) {
      return order.after;
    } else if (bIsLast) {
      return order.before;
    }

    if (aVal < bVal) {
      return order.before;
    } else if (aVal > bVal) {
      return order.after;
    }

    return order.neutral;
  });
};
