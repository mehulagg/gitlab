import dateFormat from 'dateformat';
import { getDatesInRange, nDaysBefore, getStartOfDay } from '~/lib/utils/datetime_utility';
import { CHART_TITLE } from './constants';

/**
 * Converts the raw data fetched from the
 * [Deployment Frequency API](https://docs.gitlab.com/ee/api/project_analytics.html#list-project-deployment-frequencies)
 * into series data consumable by
 * [GlAreaChart](https://gitlab-org.gitlab.io/gitlab-ui/?path=/story/charts-area-chart--default)
 *
 * @param {Array} apiData The raw JSON data from the API request
 * @param {Date} startDate The first day (inclusive) of the graph's date range
 * @param {Date} endDate The last day (exclusive) of the graph's date range
 */
export const apiDataToChartSeries = (apiData, startDate, endDate) => {
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

  // Fill in the API data (the API data doesn't included data points for
  // days with 0 deployments) and transform it for use in the graph
  const data = dates.map((date) => {
    const formattedDate = dateFormat(date, 'mmm d', true);
    return [formattedDate, timestampToApiValue[date.getTime()] || 0];
  });

  return [
    {
      name: CHART_TITLE,
      data,
    },
  ];
};
