import Vue from 'vue';
import { GlToast } from '@gitlab/ui';
import Translate from '~/vue_shared/translate';
import RegistryExplorer from './pages/index.vue';
import RegistryBreadcrumb from './components/registry_breadcrumb.vue';
import { createStore } from './stores';
import createRouter from './router';
import { apolloProvider } from './graphql/index';

Vue.use(Translate);
Vue.use(GlToast);

export default () => {
  const el = document.getElementById('js-container-registry');

  if (!el) {
    return null;
  }

  const { endpoint } = el.dataset;

  // This is a mini state to help the breadcrumb have the correct name in the details page
  const breadCrumbState = Vue.observable({
    name: '',
    updateName(value) {
      this.name = value;
    },
  });

  const store = createStore();
  const router = createRouter(endpoint, breadCrumbState);
  store.dispatch('setInitialState', el.dataset);

  const attachMainComponent = () =>
    new Vue({
      el,
      store,
      router,
      apolloProvider,
      components: {
        RegistryExplorer,
      },
      provide() {
        return { breadCrumbState };
      },
      render(createElement) {
        return createElement('registry-explorer');
      },
    });

  const attachBreadcrumb = () => {
    const breadCrumbEl = document.querySelector('nav .js-breadcrumbs-list');
    const crumbs = [...document.querySelectorAll('.js-breadcrumbs-list li')];
    return new Vue({
      el: breadCrumbEl,
      router,
      apolloProvider,
      components: {
        RegistryBreadcrumb,
      },
      render(createElement) {
        return createElement('registry-breadcrumb', {
          class: breadCrumbEl.className,
          props: {
            crumbs,
          },
        });
      },
    });
  };

  return { attachBreadcrumb, attachMainComponent };
};
