import Vue from 'vue';
import VueApollo from 'vue-apollo';
import $ from 'jquery';
import Cookies from 'js-cookie';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import createDefaultClient from '~/lib/graphql';
import BurnCharts from './components/burn_charts.vue';

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

    // eslint-disable-next-line no-new
    new Vue({
      el: container,
      components: {
        BurnCharts,
      },
      mixins: [glFeatureFlagsMixin()],
      data() {
        return {
          openIssuesCount: [],
          openIssuesWeight: [],
        };
      },
      apolloProvider,
      render(createElement) {
        return createElement('burn-charts', {
          props: {
            burndownEventsPath,
            startDate,
            dueDate,
            openIssuesCount: this.openIssuesCount,
            openIssuesWeight: this.openIssuesCount,
            milestoneId,
          },
        });
      },
    });
  }
};
