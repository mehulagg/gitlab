<script>
import dateFormat from 'dateformat';
import Api from 'ee/api';
import { s__, sprintf } from '~/locale';
import createFlash from '~/flash';
import * as Sentry from '~/sentry/wrapper';
import { nDaysBefore, nMonthsBefore, getDatesInRange } from '~/lib/utils/datetime_utility';
import CiCdAnalyticsAreaChart from '~/projects/pipelines/charts/components/ci_cd_analytics_area_chart.vue';

export default {
  name: 'DeploymentFrequencyCharts',
  components: {
    CiCdAnalyticsAreaChart,
  },
  inject: {
    projectPath: {
      type: String,
      default: '',
    },
  },
  data() {
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

    return {
      charts: [
        {
          title: sprintf(
            s__(
              'DeploymentFrequencyCharts|Deployments to production for last week (%{startDate} - %{endDate})',
            ),
            {
              startDate: dateFormat(lastWeek, titleDateFormatString),
              endDate: dateFormat(startOfToday, titleDateFormatString),
            },
          ),
          startDate: lastWeek,
          requestParams: {
            ...sharedRequestParams,
            from: dateFormat(lastWeek, apiDateFormatString),
          },
          isLoading: true,
          data: [],
        },
        {
          title: sprintf(
            s__(
              'DeploymentFrequencyCharts|Deployments to production for last month (%{startDate} - %{endDate})',
            ),
            {
              startDate: dateFormat(lastMonth, titleDateFormatString),
              endDate: dateFormat(startOfToday, titleDateFormatString),
            },
          ),
          startDate: lastMonth,
          requestParams: {
            ...sharedRequestParams,
            from: dateFormat(lastMonth, apiDateFormatString),
          },
          isLoading: true,
          data: [],
        },
        {
          title: sprintf(
            s__(
              'DeploymentFrequencyCharts|Deployments to production for the last 90 days (%{startDate} - %{endDate})',
            ),
            {
              startDate: dateFormat(last90Days, titleDateFormatString),
              endDate: dateFormat(startOfToday, titleDateFormatString),
            },
          ),
          startDate: last90Days,
          requestParams: {
            ...sharedRequestParams,
            from: dateFormat(last90Days, apiDateFormatString),
          },
          isLoading: true,
          data: [],
        },
      ],
    };
  },
  async mounted() {
    const results = await Promise.allSettled(
      this.charts.map(async (c) => {
        const chart = c;

        chart.isLoading = true;
        try {
          const { data: apiData } = await Api.deploymentFrequencies(
            this.projectPath,
            chart.requestParams,
          );

          chart.data = this.apiDataToChartSeries(apiData, chart.startDate);
        } finally {
          chart.isLoading = false;
        }
      }),
    );

    const requestErrors = results.filter((r) => r.status === 'rejected').map((r) => r.reason);

    if (requestErrors.length) {
      createFlash({
        message: s__(
          'DeploymentFrequencyCharts|Something went wrong while getting deployment frequency data',
        ),
      });

      const allErrorMessages = requestErrors.join('\n');
      Sentry.captureException(
        new Error(
          `Something went wrong while getting deployment frequency data:\n${allErrorMessages}`,
        ),
      );
    }
  },
  methods: {
    /**
     * Converts the raw data fetched from the
     * [Deployment Frequency API](https://docs.gitlab.com/ee/api/project_analytics.html#list-project-deployment-frequencies)
     * into series data consumable by
     * [GlAreaChart](https://gitlab-org.gitlab.io/gitlab-ui/?path=/story/charts-area-chart--default)
     *
     * @param apiData The raw JSON data from the API request
     * @param startDate The first day that should be rendered on the graph
     */
    apiDataToChartSeries(apiData, startDate) {
      // Get a list of dates (formatted identically to the dates in the API response),
      // one date per day in the graph's date range
      const dates = getDatesInRange(startDate, new Date(), (date) =>
        dateFormat(date, 'yyyy-mm-dd'),
      );

      // Fill in the API data (the API data doesn't included data points for
      // days with 0 deployments) and transform it for use in the graph
      const data = dates.map((date) => {
        const value = apiData.find((dataPoint) => dataPoint.from === date)?.value || 0;
        const formattedDate = dateFormat(new Date(date), 'mmm d');
        return [formattedDate, value];
      });

      return [
        {
          name: s__('DeploymentFrequencyCharts|Deployments'),
          data,
        },
      ];
    },
  },
  areaChartOptions: {
    xAxis: {
      name: s__('DeploymentFrequencyCharts|Date'),
      type: 'category',
    },
    yAxis: {
      name: s__('DeploymentFrequencyCharts|Deployments'),
      type: 'value',
      minInterval: 1,
    },
  },
};
</script>
<template>
  <div>
    <h4 class="gl-my-4">{{ s__('DeploymentFrequencyCharts|Deployments charts') }}</h4>
    <ci-cd-analytics-area-chart
      v-for="(chart, index) in charts"
      :key="index"
      :chart-data="chart.data"
      :area-chart-options="$options.areaChartOptions"
    >
      {{ chart.title }}
    </ci-cd-analytics-area-chart>
  </div>
</template>
