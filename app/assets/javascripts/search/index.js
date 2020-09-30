import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import { queryToObject } from '~/lib/utils/url_utility';
import createStore from './store';
import SearchApp from './components/app.vue';

Vue.use(Translate);

export default () => {
  const el = document.getElementById('js-search-app');

  if (!el) return false;

  const props = {
    html: el.innerHTML,
  };

  const { scope } = el.dataset;

  const app = new Vue({
    el,
    store: createStore({ scope, query: queryToObject(window.location.search) }),
    render(h) {
      return h(SearchApp, { props });
    },
  });

  return app;
};
