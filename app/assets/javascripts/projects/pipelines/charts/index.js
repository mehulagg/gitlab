import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import ProjectPipelinesCharts from './components/app.vue';
import ProjectPipelinesChartsNew from './components/app_graphql.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

export default () => {
  const el = document.querySelector('#js-project-pipelines-charts-app');
  const {
    countsFailed,
    countsSuccess,
    countsTotal,
    countsTotalDuration,
    successRatio,
    timesChartLabels,
    timesChartValues,
    lastWeekChartLabels,
    lastWeekChartTotals,
    lastWeekChartSuccess,
    lastMonthChartLabels,
    lastMonthChartTotals,
    lastMonthChartSuccess,
    lastYearChartLabels,
    lastYearChartTotals,
    lastYearChartSuccess,
    projectPath,
  } = el.dataset;

  const parseAreaChartData = (labels, totals, success) => ({
    labels: JSON.parse(labels),
    totals: JSON.parse(totals),
    success: JSON.parse(success),
  });

  if (gon.features.graphqlPipelineAnalytics) {
    return new Vue({
      el,
      name: 'ProjectPipelinesChartsApp',
      components: {
        ProjectPipelinesChartsNew,
      },
      apolloProvider,
      provide: {
        projectPath,
      },
      render: createElement => createElement(ProjectPipelinesChartsNew, {}),
    });
  }

  return new Vue({
    el,
    name: 'ProjectPipelinesChartsApp',
    components: {
      ProjectPipelinesCharts,
    },
    render: createElement =>
      createElement(ProjectPipelinesCharts, {
        props: {
          counts: {
            failed: countsFailed,
            success: countsSuccess,
            total: countsTotal,
            successRatio,
            totalDuration: countsTotalDuration,
          },
          timesChartData: {
            labels: JSON.parse(timesChartLabels),
            values: JSON.parse(timesChartValues),
          },
          lastWeekChartData: parseAreaChartData(
            lastWeekChartLabels,
            lastWeekChartTotals,
            lastWeekChartSuccess,
          ),
          lastMonthChartData: parseAreaChartData(
            lastMonthChartLabels,
            lastMonthChartTotals,
            lastMonthChartSuccess,
          ),
          lastYearChartData: parseAreaChartData(
            lastYearChartLabels,
            lastYearChartTotals,
            lastYearChartSuccess,
          ),
        },
      }),
  });
};
