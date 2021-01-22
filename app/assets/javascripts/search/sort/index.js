import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import GlobalSearchSort from './components/app.vue';

Vue.use(Translate);

export const initSearchSort = (store) => {
  const el = document.getElementById('js-search-sort');

  if (!el) return false;

  return new Vue({
    el,
    store,
    render(createElement) {
      return createElement(GlobalSearchSort);
    },
  });
};
