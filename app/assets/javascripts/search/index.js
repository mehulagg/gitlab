import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import SearchApp from './components/app.vue';

Vue.use(Translate);

export default () => {
  const el = document.getElementById('js-search-app');

  if (!el) return false;

  const props = {
    html: el.innerHTML,
  };

  const app = new Vue({
    el,
    render(h) {
      return h(SearchApp, { props });
    },
  });

  return app;
};
