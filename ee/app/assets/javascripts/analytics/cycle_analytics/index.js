import Vue from 'vue';
import { GlToast } from '@gitlab/ui';
import CycleAnalytics from './components/base.vue';
import createStore from './store';
import { buildCycleAnalyticsInitialData } from '../shared/utils';
import { parseBoolean } from '~/lib/utils/common_utils';

Vue.use(GlToast);

export default () => {
  const el = document.querySelector('#js-cycle-analytics-app');
  const { emptyStateSvgPath, noDataSvgPath, noAccessSvgPath, hideGroupDropDown } = el.dataset;
  const initialData = buildCycleAnalyticsInitialData(el.dataset);
  const store = createStore();
  const {
    cycleAnalyticsScatterplotEnabled: hasDurationChart = false,
    valueStreamAnalyticsPathNavigation: hasPathNavigation = false,
    valueStreamAnalyticsCreateMultipleValueStreams: hasCreateMultipleValueStreams = false,
    analyticsSimilaritySearch: hasAnalyticsSimilaritySearch = false,
  } = gon?.features;

  store.dispatch('initializeCycleAnalytics', {
    ...initialData,
    featureFlags: {
      hasDurationChart,
      hasPathNavigation,
      hasCreateMultipleValueStreams,
      hasAnalyticsSimilaritySearch,
    },
  });

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
        },
      }),
  });
};
