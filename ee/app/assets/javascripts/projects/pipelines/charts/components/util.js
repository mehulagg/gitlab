import dateFormat from 'dateformat';
import { getDatesInRange } from '~/lib/utils/datetime_utility';
import { CHART_TITLE } from './constants';

/**
 * Converts the raw data fetched from the
 * [Deployment Frequency API](https://docs.gitlab.com/ee/api/project_analytics.html#list-project-deployment-frequencies)
 * into series data consumable by
 * [GlAreaChart](https://gitlab-org.gitlab.io/gitlab-ui/?path=/story/charts-area-chart--default)
 *
 * @param apiData The raw JSON data from the API request
 * @param startDate The first day that should be rendered on the graph
 */
export const apiDataToChartSeries = (apiData, startDate) => {
  // Get a list of dates (formatted identically to the dates in the API response),
  // one date per day in the graph's date range
  const dates = getDatesInRange(startDate, new Date(), (date) => dateFormat(date, 'yyyy-mm-dd'));

  // Fill in the API data (the API data doesn't included data points for
  // days with 0 deployments) and transform it for use in the graph
  const data = dates.map((date) => {
    const value = apiData.find((dataPoint) => dataPoint.from === date)?.value || 0;
    const formattedDate = dateFormat(new Date(date), 'mmm d');
    return [formattedDate, value];
  });

  return [
    {
      name: CHART_TITLE,
      data,
    },
  ];
};
