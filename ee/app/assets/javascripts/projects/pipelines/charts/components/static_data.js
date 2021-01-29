import dateFormat from 'dateformat';
import { __, s__, sprintf } from '~/locale';
import { helpPagePath } from '~/helpers/help_page_helper';
import { nDaysBefore, nMonthsBefore } from '~/lib/utils/datetime_utility';
import { LAST_WEEK, LAST_MONTH, LAST_90_DAYS } from './constants';

// Compute all relative dates based on the _beginning_ of today
const startOfToday = new Date(new Date().setHours(0, 0, 0, 0));
const lastWeek = new Date(nDaysBefore(startOfToday, 7));
const lastMonth = new Date(nMonthsBefore(startOfToday, 1));
const last90Days = new Date(nDaysBefore(startOfToday, 90));
const apiDateFormatString = 'isoDateTime';
const titleDateFormatString = 'mmm d';
const sharedRequestParams = {
  environment: 'production',
  interval: 'daily',

  // We will never have more than 91 records (1 record per day), so we
  // don't have to worry about making multiple requests to get all the results
  per_page: 100,
};

export const allChartDefinitions = [
  {
    id: LAST_WEEK,
    title: __('Last week'),
    range: sprintf(s__('DeploymentFrequencyCharts|%{startDate} - %{endDate}'), {
      startDate: dateFormat(lastWeek, titleDateFormatString),
      endDate: dateFormat(startOfToday, titleDateFormatString),
    }),
    startDate: lastWeek,
    requestParams: {
      ...sharedRequestParams,
      from: dateFormat(lastWeek, apiDateFormatString),
    },
  },
  {
    id: LAST_MONTH,
    title: __('Last month'),
    range: sprintf(s__('DeploymentFrequencyCharts|%{startDate} - %{endDate}'), {
      startDate: dateFormat(lastMonth, titleDateFormatString),
      endDate: dateFormat(startOfToday, titleDateFormatString),
    }),
    startDate: lastMonth,
    requestParams: {
      ...sharedRequestParams,
      from: dateFormat(lastMonth, apiDateFormatString),
    },
  },
  {
    id: LAST_90_DAYS,
    title: __('Last 90 days'),
    range: sprintf(s__('%{startDate} - %{endDate}'), {
      startDate: dateFormat(last90Days, titleDateFormatString),
      endDate: dateFormat(startOfToday, titleDateFormatString),
    }),
    startDate: last90Days,
    requestParams: {
      ...sharedRequestParams,
      from: dateFormat(last90Days, apiDateFormatString),
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
