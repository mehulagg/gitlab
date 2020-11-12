import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { urlQueryToFilter } from '~/vue_shared/components/filtered_search_bar/filtered_search_utils';
import { getDateInPast } from '~/lib/utils/datetime_utility';
import { getParameterValues } from '~/lib/utils/url_utility';
import createStore from './store';
import MergeRequestAnalyticsApp from './components/app.vue';
import { ITEM_TYPE } from '~/groups/constants';
import { DEFAULT_NUMBER_OF_DAYS } from './constants';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

export default () => {
  const el = document.querySelector('#js-merge-request-analytics-app');

  if (!el) return false;

  const { type, fullPath, milestonePath, labelsPath } = el.dataset;
  const store = createStore();

  store.dispatch('filters/setEndpoints', {
    milestonesEndpoint: milestonePath,
    labelsEndpoint: labelsPath,
    groupEndpoint: type === ITEM_TYPE.GROUP ? fullPath : null,
    projectEndpoint: type === ITEM_TYPE.PROJECT ? fullPath : null,
  });
  const {
    source_branch_name = null,
    target_branch_name = null,
    assignee_username = null,
    author_username = null,
    milestone_title = null,
    label_name = [],
  } = urlQueryToFilter(window.location.search);
  store.dispatch('filters/initialize', {
    selectedSourceBranch: source_branch_name,
    selectedTargetBranch: target_branch_name,
    selectedAssignee: assignee_username,
    selectedAuthor: author_username,
    selectedMilestone: milestone_title,
    selectedLabelList: label_name,
  });

  const startDateParam = getParameterValues('start_date');
  const endDateParam = getParameterValues('end_date');

  return new Vue({
    el,
    apolloProvider,
    store,
    name: 'MergeRequestAnalyticsApp',
    provide: {
      fullPath,
      type,
    },
    render: createElement =>
      createElement(MergeRequestAnalyticsApp, {
        props: {
          startDate: startDateParam.length
            ? new Date(startDateParam)
            : getDateInPast(new Date(), DEFAULT_NUMBER_OF_DAYS),
          endDate: endDateParam.length ? new Date(endDateParam) : new Date(),
        },
      }),
  });
};
