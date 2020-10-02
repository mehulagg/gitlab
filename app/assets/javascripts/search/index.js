import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import { queryToObject } from '~/lib/utils/url_utility';
import createStore from './store';

import { VueMountComponent } from './lib/helpers';
import { FILTER_TYPES, FILTER_DATA_BY_TYPE } from './constants';
import DropdownFilter from './components/dropdown_filter.vue';

Vue.use(Translate);
Vue.use(VueMountComponent);

export default () => {
  const el = document.getElementById('js-search-app');

  if (!el) return false;

  const { scope } = el.dataset;

  const app = new Vue({
    el,
    name: 'GlobalSearchApp',
    store: createStore({ scope, query: queryToObject(window.location.search) }),
    mounted() {
      this.$mountComponent(
        DropdownFilter,
        { filterData: FILTER_DATA_BY_TYPE[FILTER_TYPES.STATE] },
        '#js-search-filter-by-state',
      );

      this.$mountComponent(
        DropdownFilter,
        { filterData: FILTER_DATA_BY_TYPE[FILTER_TYPES.CONFIDENTIAL] },
        '#js-search-filter-by-confidential',
      );
    },
  });

  return app;
};
