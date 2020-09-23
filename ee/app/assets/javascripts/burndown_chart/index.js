import Vue from 'vue';
import VueApollo from 'vue-apollo';
import $ from 'jquery';
import Cookies from 'js-cookie';
import createDefaultClient from '~/lib/graphql';
import BurnCharts from './components/burn_charts.vue';
import BurndownChartData from './burn_chart_data';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

export default () => {
  // handle hint dismissal
  const hint = $('.burndown-hint');
  hint.on('click', '.dismiss-icon', () => {
    hint.hide();
    Cookies.set('hide_burndown_message', 'true');
  });

  // generate burndown chart (if data available)
  const container = '.burndown-chart';
  const $chartEl = $(container);

  if ($chartEl.length) {
    const startDate = $chartEl.data('startDate');
    const dueDate = $chartEl.data('dueDate');
    const milestoneId = $chartEl.data('milestoneId');
    const burndownEventsPath = $chartEl.data('burndownEventsPath');

    axios
      .get(burndownEventsPath)
      .then(burndownResponse => {
        const burndownEvents = burndownResponse.data;
        const burndownChartData = new BurndownChartData(
          burndownEvents,
          startDate,
          dueDate,
        ).generateBurndownTimeseries();

        const openIssuesCount = burndownChartData.map(d => [d[0], d[1]]);
        const openIssuesWeight = burndownChartData.map(d => [d[0], d[2]]);

        return new Vue({
          el: container,
          components: {
            BurnCharts,
          },
          apolloProvider,
          render(createElement) {
            return createElement('burn-charts', {
              props: {
                startDate,
                dueDate,
                openIssuesCount,
                openIssuesWeight,
                milestoneId,
              },
            });
          },
        });
      })
      .catch(() => {
        createFlash(__('Error loading burndown chart data'));
      });
  }
};
