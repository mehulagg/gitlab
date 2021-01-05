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

  return new Vue({
    el,
    apolloProvider: new VueApollo({ defaultClient: createDefaultClient() }),
    store: new Vuex.Store(createStore(el.dataset)),
    render(createElement) {
      return createElement(TerraformList);
    },
  });
};
