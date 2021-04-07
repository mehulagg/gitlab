import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { resolvers } from './graphql/resolvers';

Vue.use(VueApollo);

const defaultClient = createDefaultClient(resolvers, { assumeImmutableResults: true });

export default new VueApollo({
  defaultClient,
});
