import Vue from 'vue';
import VueApollo from 'vue-apollo';
import Vuex from 'vuex';
import createDefaultClient from '~/lib/graphql';
import ResponsiveApp from './components/responsive_app.vue';
import App from './components/top_nav_app_with_callout.vue';
import { createStore } from './stores';

Vue.use(Vuex);
Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

const mount = (el, Component) => {
  const viewModel = JSON.parse(el.dataset.viewModel);
  const store = createStore();

  return new Vue({
    el,
    store,
    apolloProvider,
    render(h) {
      return h(Component, {
        props: {
          navData: viewModel,
        },
      });
    },
  });
};

export const mountTopNav = (el) => mount(el, App);

export const mountTopNavResponsive = (el) => mount(el, ResponsiveApp);
