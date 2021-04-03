import dateFormat from 'dateformat';
import { helpPagePath } from '~/helpers/help_page_helper';
import { nDaysBefore, nMonthsBefore, getStartOfDay, dayAfter } from '~/lib/utils/datetime_utility';
import { __, s__, sprintf } from '~/locale';
import { LAST_WEEK, LAST_MONTH, LAST_90_DAYS } from './constants';

// Compute all relative dates based on the _beginning_ of today.
// We use this date as the end date for the charts. This causes
// the current date to be the last day included in the graph.
const startOfToday = getStartOfDay(new Date(), { utc: true });

// We use this date as the "to" parameter for the API. This allows
// us to get deployment information about the current day.
const startOfTomorrow = dayAfter(startOfToday, { utc: true });

const lastWeek = nDaysBefore(startOfTomorrow, 7, { utc: true });
const lastMonth = nMonthsBefore(startOfTomorrow, 1, { utc: true });
const last90Days = nDaysBefore(startOfTomorrow, 90, { utc: true });
const apiDateFormatString = 'isoDateTime';
const titleDateFormatString = 'mmm d';
const sharedRequestParams = {
  interval: 'daily',
  end_date: dateFormat(startOfTomorrow, apiDateFormatString, true),

  // We will never have more than 91 records (1 record per day), so we
  // don't have to worry about making multiple requests to get all the results
  per_page: 100,
};

export const allChartDefinitions = [
  {
    id: LAST_WEEK,
    title: __('Last week'),
    range: sprintf(s__('DeploymentFrequencyCharts|%{startDate} - %{endDate}'), {
      startDate: dateFormat(lastWeek, titleDateFormatString, true),
      endDate: dateFormat(startOfToday, titleDateFormatString, true),
    }),
    startDate: lastWeek,
    endDate: startOfTomorrow,
    requestParams: {
      ...sharedRequestParams,
      start_date: dateFormat(lastWeek, apiDateFormatString, true),
    },
  },
  {
    id: LAST_MONTH,
    title: __('Last month'),
    range: sprintf(s__('DeploymentFrequencyCharts|%{startDate} - %{endDate}'), {
      startDate: dateFormat(lastMonth, titleDateFormatString, true),
      endDate: dateFormat(startOfToday, titleDateFormatString, true),
    }),
    startDate: lastMonth,
    endDate: startOfTomorrow,
    requestParams: {
      ...sharedRequestParams,
      start_date: dateFormat(lastMonth, apiDateFormatString, true),
    },
  },
  {
    id: LAST_90_DAYS,
    title: __('Last 90 days'),
    range: sprintf(s__('%{startDate} - %{endDate}'), {
      startDate: dateFormat(last90Days, titleDateFormatString, true),
      endDate: dateFormat(startOfToday, titleDateFormatString, true),
    }),
    startDate: last90Days,
    endDate: startOfTomorrow,
    requestParams: {
      ...sharedRequestParams,
      start_date: dateFormat(last90Days, apiDateFormatString, true),
    },
  },
];

export const areaChartOptions = {
  xAxis: {
    name: s__('DeploymentFrequencyCharts|Date'),
    type: 'category',
  },
  yAxis: {
    name: s__('DeploymentFrequencyCharts|Deployments'),
    type: 'value',
    minInterval: 1,
  },
};

export const chartDescriptionText = s__(
  'DeploymentFrequencyCharts|These charts display the frequency of deployments to the production environment, as part of the DORA 4 metrics. The environment must be named %{codeStart}production%{codeEnd} for its data to appear in these charts.',
);

export const chartDocumentationHref = helpPagePath('user/analytics/ci_cd_analytics.html', {
  anchor: 'deployment-frequency-charts',
});
