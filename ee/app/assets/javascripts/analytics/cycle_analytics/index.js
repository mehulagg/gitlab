import { GlToast } from '@gitlab/ui';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { urlQueryToFilter } from '~/vue_shared/components/filtered_search_bar/filtered_search_utils';
import { buildCycleAnalyticsInitialData } from '../shared/utils';
import CycleAnalytics from './components/base.vue';
import createStore from './store';

Vue.use(GlToast);
Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

export default () => {
  const el = document.querySelector('#js-cycle-analytics-app');
  const { emptyStateSvgPath, noDataSvgPath, noAccessSvgPath } = el.dataset;
  const initialData = buildCycleAnalyticsInitialData(el.dataset);
  const store = createStore();
  const {
    cycleAnalyticsScatterplotEnabled: hasDurationChart = false,
    valueStreamAnalyticsPathNavigation: hasPathNavigation = false,
  } = gon?.features;

  console.log('filters', urlQueryToFilter(window.location.search));

  const {
    author_username = null,
    milestone_title = null,
    assignee_username = [],
    label_name = [],
    sort,
    direction,
    page,
  } = urlQueryToFilter(window.location.search);

  console.log('BASE::sort', sort);
  console.log('BASE::direction', direction);

  store.dispatch('initializeCycleAnalytics', {
    ...initialData,
    selectedAuthor: author_username,
    selectedMilestone: milestone_title,
    selectedAssigneeList: assignee_username,
    selectedLabelList: label_name,
    featureFlags: {
      hasDurationChart,
      hasPathNavigation,
    },
    pagination: {
      page: page?.value || 1,
      sort: sort?.value || null,
      direction: direction?.value || null,
    },
  });

  return new Vue({
    el,
    name: 'CycleAnalyticsApp',
    apolloProvider,
    store,
    render: (createElement) =>
      createElement(CycleAnalytics, {
        props: {
          emptyStateSvgPath,
          noDataSvgPath,
          noAccessSvgPath,
        },
      }),
  });
};
