import Vue from 'vue';
// eslint-disable-next-line import/no-deprecated
import { urlParamsToObject } from '~/lib/utils/url_utility';
import IssuesAnalytics from './components/issues_analytics.vue';
import store from './stores';

export default () => {
  const el = document.querySelector('#js-issues-analytics');
  const filterBlockEl = document.querySelector('.issues-filters');

  if (!el) return null;

  const {
    endpoint,
    noDataEmptyStateSvgPath,
    filtersEmptyStateSvgPath,
    issuesApiEndpoint,
    issuesPageEndpoint,
  } = el.dataset;

  // Set default filters from URL
  // eslint-disable-next-line import/no-deprecated
  const filters = urlParamsToObject(window.location.search);
  store.dispatch('issueAnalytics/setFilters', filters);

  return new Vue({
    el,
    store,
    components: {
      IssuesAnalytics,
    },
    render(createElement) {
      return createElement('issues-analytics', {
        props: {
          endpoint,
          filterBlockEl,
          noDataEmptyStateSvgPath,
          filtersEmptyStateSvgPath,
          issuesApiEndpoint,
          issuesPageEndpoint,
        },
      });
    },
  });
};
