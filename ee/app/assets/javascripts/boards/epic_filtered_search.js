import Vue from 'vue';
import store from '~/boards/stores';
import { queryToObject } from '~/lib/utils/url_utility';
import EpicFilteredSearch from 'ee_component/boards/components/epic_filtered_search.vue';

export default () => {
  const queryParams = queryToObject(window.location.search);
  const el = document.getElementById('js-board-filtered-search');

  return new Vue({
    el,
    store,
    apolloProvider: {},
    render: (createElement) =>
      createElement(EpicFilteredSearch, {
        props: { search: queryParams.search },
      }),
  });
};
