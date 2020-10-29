import Vue from 'vue';
import VueApollo from 'vue-apollo';
import Translate from '~/vue_shared/translate';
import { createApolloClient } from './graphql/client_factory';
import ImportTable from './components/import_table.vue';
// import { parseBoolean } from '../lib/utils/common_utils';
// import { queryToObject } from '../lib/utils/url_utility';
// import createStore from './store';

Vue.use(Translate);
Vue.use(VueApollo);

export function mountImportGroupsApp(mountElement) {
  if (!mountElement) return undefined;

  const { statusPath, availableNamespacesPath } = mountElement.dataset;
  const apolloProvider = new VueApollo({
    defaultClient: createApolloClient({
      endpoints: {
        status: statusPath,
        availableNamespaces: availableNamespacesPath,
      },
    }),
  });

  return new Vue({
    el: mountElement,
    apolloProvider,
    render(createElement) {
      return createElement(ImportTable);
    },
  });
}
