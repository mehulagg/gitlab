import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { resolvers } from 'ee/pages/admin/cloud_licenses/graphql/resolvers';
import typeDefs from 'ee/pages/admin/cloud_licenses/graphql/typedefs.graphql';
import createDefaultClient from '~/lib/graphql';
import CloudLicenseShowApp from '../components/app.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(resolvers, {
    typeDefs,
    assumeImmutableResults: true,
  }),
});

export default () => {
  const el = document.getElementById('js-show-cloud-license-page');

  return new Vue({
    el,
    apolloProvider,
    render: (h) => h(CloudLicenseShowApp),
  });
};
