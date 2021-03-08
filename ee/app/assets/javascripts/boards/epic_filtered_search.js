import Vue from 'vue';
import store from '~/boards/stores';
import { queryToObject } from '~/lib/utils/url_utility';
import FilteredSearch from 'ee_component/boards/components/filtered_search.vue';

export default () => {
  const queryParams = queryToObject(window.location.search);
  const el = document.getElementById('js-board-filtered-search');

  return new Vue({
    el,
    store,
    apolloProvider: {},
    render: (createElement) =>
      createElement(FilteredSearch, {
        props: { search: queryParams.search },
      }),
  });
};
