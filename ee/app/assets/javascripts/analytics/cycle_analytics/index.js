import Vue from 'vue';
import CycleAnalytics from './components/base.vue';
import createStore from './store';
import { buildCycleAnalyticsInitialData } from '../shared/utils';
import { parseBoolean } from '~/lib/utils/common_utils';

export default () => {
  const el = document.querySelector('#js-cycle-analytics-app');
  console.log('dataset', el.dataset);
  const {
    emptyStateSvgPath,
    noDataSvgPath,
    noAccessSvgPath,
    hideGroupDropDown,
    milestonePath = '',
    labelsPath = '',
    authorPath = '',
    assigneesPath = '',
  } = el.dataset;

  const initialData = buildCycleAnalyticsInitialData(el.dataset);
  const store = createStore();
  store.dispatch('initializeCycleAnalytics', initialData);

  return new Vue({
    el,
    name: 'CycleAnalyticsApp',
    store,
    render: createElement =>
      createElement(CycleAnalytics, {
        props: {
          emptyStateSvgPath,
          noDataSvgPath,
          noAccessSvgPath,
          hideGroupDropDown: parseBoolean(hideGroupDropDown),
          milestonePath,
          labelsPath,
          authorPath,
          assigneesPath,
        },
      }),
  });
};
