import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import { queryToObject } from '~/lib/utils/url_utility';
import createStore from './store';

import { VueMountComponent } from './lib/helpers';

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
  });

  return app;
};
