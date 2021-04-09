import dateFormat from 'dateformat';
import { getDatesInRange, nDaysBefore, getStartOfDay } from '~/lib/utils/datetime_utility';

/**
 * Converts the raw data fetched from the
 * [DORA Metrics API](https://docs.gitlab.com/ee/api/dora/metrics.html#get-project-level-dora-metrics)
 * into series data consumable by
 * [GlAreaChart](https://gitlab-org.gitlab.io/gitlab-ui/?path=/story/charts-area-chart--default)
 *
 * @param {Array} apiData The raw JSON data from the API request
 * @param {Date} startDate The first day (inclusive) of the graph's date range
 * @param {Date} endDate The last day (exclusive) of the graph's date range
 * @param {String} seriesName The name of the series
 * @param {*} emptyValue The value to substitute if the API data doesn't
 * include data for a particular date
 */
export const apiDataToChartSeries = (apiData, startDate, endDate, seriesName, emptyValue = 0) => {
  // Get a list of dates, one date per day in the graph's date range
  const beginningOfStartDate = getStartOfDay(startDate, { utc: true });
  const beginningOfEndDate = nDaysBefore(getStartOfDay(endDate, { utc: true }), 1, { utc: true });
  const dates = getDatesInRange(beginningOfStartDate, beginningOfEndDate).map((d) =>
    getStartOfDay(d, { utc: true }),
  );

  // Generate a map of API timestamps to its associated value.
  // The timestamps are explicitly set to the _beginning_ of the day (in UTC)
  // so that we can confidently compare dates by value below.
  const timestampToApiValue = apiData.reduce((acc, curr) => {
    const apiTimestamp = getStartOfDay(new Date(curr.date), { utc: true }).getTime();
    acc[apiTimestamp] = curr.value;
    return acc;
  }, {});

  // Fill in the API data (the API may exclude data points for dates that have no data)
  // and transform it for use in the graph
  const data = dates.map((date) => {
    const formattedDate = dateFormat(date, 'mmm d', true);
    return [formattedDate, timestampToApiValue[date.getTime()] ?? emptyValue];
  });

  return [
    {
      name: seriesName,
      data,
    },
  ];
};
