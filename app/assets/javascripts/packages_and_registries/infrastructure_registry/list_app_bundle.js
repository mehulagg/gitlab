import Vue from 'vue';
import PackagesListApp from '~/packages/list/components/packages_list_app.vue';
import { createStore } from '~/packages/list/stores';
import Translate from '~/vue_shared/translate';

Vue.use(Translate);

export default () => {
  const el = document.getElementById('js-vue-packages-list');
  const store = createStore();
  store.dispatch('setInitialState', el.dataset);

  return new Vue({
    el,
    store,
    components: {
      PackagesListApp,
    },
    provide: {
      titleComponent: 'InfrastructureTitle',
      searchComponent: 'InfrastructureSearch',
    },
    render(createElement) {
      return createElement('packages-list-app');
    },
  });
};
