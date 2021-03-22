import resolvers from 'ee/vue_shared/purchase_flow/graphql/resolvers';
import typeDefs from 'ee/vue_shared/purchase_flow/graphql/typedefs.graphql';
import createDefaultClient from '~/lib/graphql';

export default createDefaultClient(resolvers, {
  typeDefs,
  assumeImmutableResults: true,
});
