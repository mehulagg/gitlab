import Vue from 'vue';
import VueApollo from 'vue-apollo';
import Vuex from 'vuex';
import TerraformList from './components/terraform_list.vue';
import createDefaultClient from '~/lib/graphql';
import createStore from './store';

Vue.use(VueApollo);
Vue.use(Vuex);

export default () => {
  const el = document.querySelector('#js-terraform-list');

  if (!el) {
    return null;
  }

  const defaultClient = createDefaultClient();

  const { emptyStateImage, projectPath } = el.dataset;

  return new Vue({
    el,
    apolloProvider: new VueApollo({ defaultClient }),
    store: createStore(el.dataset),
    render(createElement) {
      return createElement(TerraformList, {
        props: {
          emptyStateImage,
          projectPath,
          terraformAdmin: el.hasAttribute('data-terraform-admin'),
        },
      });
    },
  });
};
