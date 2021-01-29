import dateFormat from 'dateformat';
import { getDatesInRange, getStartOfDayUTC } from '~/lib/utils/datetime_utility';
import { CHART_TITLE } from './constants';

/**
 * Converts the raw data fetched from the
 * [Deployment Frequency API](https://docs.gitlab.com/ee/api/project_analytics.html#list-project-deployment-frequencies)
 * into series data consumable by
 * [GlAreaChart](https://gitlab-org.gitlab.io/gitlab-ui/?path=/story/charts-area-chart--default)
 *
 * @param {Array} apiData The raw JSON data from the API request
 * @param {Date} startDate The first day that should be rendered on the graph
 */
export const apiDataToChartSeries = (apiData, startDate) => {
  // Get a list of dates, one date per day in the graph's date range
  const beginningOfStartDate = getStartOfDayUTC(startDate);
  const dates = getDatesInRange(beginningOfStartDate, getStartOfDayUTC(new Date())).map((d) =>
    getStartOfDayUTC(d),
  );

  // Generate a map of API timestamps to its associated value.
  // The timestamps are explicitly set to the _beginning_ of the day (in UTC)
  // so that we can confidently compare dates by value below.
  const timestampToApiValue = apiData.reduce((acc, curr) => {
    const apiTimestamp = getStartOfDayUTC(new Date(curr.from)).getTime();
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
