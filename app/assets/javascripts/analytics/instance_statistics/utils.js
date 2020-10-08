import { formatDate } from '~/lib/utils/datetime_utility';

/**
 * Takes an array of items and returns one item per month with the average of the `count`s from that month
 * @param  {Array} items
 * @param  {Number} items[index].count value to be averaged
 * @param  {String} items[index].recordedAt item dateTime time stamp to be collected into a month
 * @return {Array} items collected into [month, average],
 * where month is a dateTime string representing the first of the given month
 * and average is the average of the count
 */
export function getAverageByMonth(items = []) {
  const itemsMap = items.reduce((memo, item) => {
    const { count, recordedAt } = item;
    const date = new Date(recordedAt);
    const month = formatDate(new Date(date.getFullYear(), date.getMonth(), 1), 'yyyy-mm-dd');
    if (memo[month]) {
      const { sum, recordCount } = memo[month];
      return { ...memo, [month]: { sum: sum + count, recordCount: recordCount + 1 } };
    }

    return { ...memo, [month]: { sum: count, recordCount: 1 } };
  }, {});

  return Object.keys(itemsMap).map(month => {
    const { sum, recordCount } = itemsMap[month];
    return [month, sum / recordCount];
  });
}
