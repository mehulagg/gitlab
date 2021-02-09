import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlToast } from '@gitlab/ui';
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
    valueStreamAnalyticsExtendedForm: hasExtendedFormFields = false,
  } = gon?.features;

  const {
    author_username = null,
    milestone_title = null,
    assignee_username = [],
    label_name = [],
  } = urlQueryToFilter(window.location.search);

  store.dispatch('initializeCycleAnalytics', {
    ...initialData,
    selectedAuthor: author_username,
    selectedMilestone: milestone_title,
    selectedAssigneeList: assignee_username,
    selectedLabelList: label_name,
    featureFlags: {
      hasDurationChart,
      hasPathNavigation,
      hasExtendedFormFields,
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
