import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import SearchTopbarApp from './components/app.vue';

Vue.use(Translate);

export const initTopbar = (store) => {
  const el = document.getElementById('js-search-topbar');

  if (!el) {
    return false;
  }

  let { groupInitialData, projectInitialData } = el.dataset;

  groupInitialData = JSON.parse(groupInitialData);
  projectInitialData = JSON.parse(projectInitialData);

  return new Vue({
    el,
    store,
    render(createElement) {
      return createElement(SearchTopbarApp, {
        props: {
          groupInitialData,
          projectInitialData,
        },
      });
    },
  });
};
