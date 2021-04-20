import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { resolvers } from './graphql/resolvers';
import typeDefs from './graphql/typedefs.graphql';

Vue.use(VueApollo);

const defaultClient = createDefaultClient(resolvers, { typeDefs, assumeImmutableResults: true });

export default new VueApollo({
  defaultClient,
});
