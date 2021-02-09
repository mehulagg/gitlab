import Vue from 'vue';
import { kebabCase } from 'lodash';
import { queryToObject } from '~/lib/utils/url_utility';
import store from '~/boards/stores'; // should be ee
import FilteredSearch from './components/filtered_search.vue';

export default () => {
  const queryParams = queryToObject(window.location.search);
  const el = document.getElementById('js-board-filtered-search');
  const formattedData = JSON.parse(JSON.stringify(el.dataset));
  const test = {};

  console.log(formattedData);
  Object.keys(formattedData).forEach((x) => {
    test[kebabCase(x)] = formattedData[x];
  });

  return new Vue({
    el: document.getElementById('js-board-filtered-search'),
    store,
    render: (createElement) =>
      createElement(FilteredSearch, {
        props: { search: queryParams.search, inputAttrs: test },
      }),
  });
};
