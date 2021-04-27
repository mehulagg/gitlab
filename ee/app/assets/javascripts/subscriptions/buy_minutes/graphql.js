import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createClient from '~/lib/graphql';
import { CUSTOMER_CLIENT } from './constants';
import { resolvers } from './graphql/resolvers';

Vue.use(VueApollo);

const defaultClient = createClient(resolvers, { assumeImmutableResults: true });
const customerClient = createClient(
  {},
  { path: '/-/customers_dot/proxy/graphql', useGet: true, assumeImmutableResults: true },
);

export default new VueApollo({
  defaultClient,
  clients: {
    [CUSTOMER_CLIENT]: customerClient,
  },
});
