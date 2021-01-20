import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import GlobalSearchTopbar from './components/app.vue';

Vue.use(Translate);

export const initTopbar = (store) => {
  const el = document.getElementById('js-search-topbar');

  if (!el) {
    return false;
  }

  let { groupInitialData, projectInitialData, scopeTabs } = el.dataset;

  groupInitialData = JSON.parse(groupInitialData);
  projectInitialData = JSON.parse(projectInitialData);
  scopeTabs = JSON.parse(scopeTabs);

  return new Vue({
    el,
    store,
    render(createElement) {
      return createElement(GlobalSearchTopbar, {
        props: {
          groupInitialData,
          projectInitialData,
          scopeTabs
        },
      });
    },
  });
};
