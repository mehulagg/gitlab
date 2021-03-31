import Vue from 'vue';
import EpicFilteredSearch from 'ee_component/boards/components/epic_filtered_search.vue';
import store from '~/boards/stores';
import { queryToObject } from '~/lib/utils/url_utility';

export default (apolloProvider) => {
  const queryParams = queryToObject(window.location.search);
  const el = document.getElementById('js-board-filtered-search');

  if (!el) {
    return null;
  }

  return new Vue({
    el,
    provide: {
      search: queryParams?.search || '',
    },
    store, // TODO: https://gitlab.com/gitlab-org/gitlab/-/issues/324094
    apolloProvider,
    render: (createElement) => createElement(EpicFilteredSearch),
  });
};
