import Vue from 'vue';
import Translate from '../vue_shared/translate';
import CycleAnalytics from './components/base.vue';
import CycleAnalyticsStore from './cycle_analytics_store';
import createStore from './store';

Vue.use(Translate);

export default () => {
  const store = createStore();
  const el = document.querySelector('#js-cycle-analytics');
  const { noAccessSvgPath, noDataSvgPath, requestPath } = el.dataset;

  store.dispatch('initialize', {
    requestPath,
  });

  // eslint-disable-next-line no-new
  new Vue({
    el,
    name: 'CycleAnalytics',
    store,
    render: (createElement) =>
      createElement(CycleAnalytics, {
        props: {
          noDataSvgPath,
          noAccessSvgPath,
          legacyStore: CycleAnalyticsStore,
        },
      }),
  });
};
