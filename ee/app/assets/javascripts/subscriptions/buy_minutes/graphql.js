import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createClient from '~/lib/graphql';
import { GITLAB_CLIENT, CUSTOMER_CLIENT } from './constants';
import { resolvers } from './graphql/resolvers';
import purchaseFlowResolvers from 'ee/vue_shared/purchase_flow/graphql/resolvers';

Vue.use(VueApollo);

const gitlabClient = createClient(
  { ...resolvers, ...purchaseFlowResolvers },
  { assumeImmutableResults: true },
);
const customerClient = createClient(
  { ...resolvers, ...purchaseFlowResolvers },
  {
    path: '/-/customers_dot/proxy/graphql',
    useGet: true,
    assumeImmutableResults: true,
  },
);

export default new VueApollo({
  defaultClient: gitlabClient,
  clients: {
    [GITLAB_CLIENT]: gitlabClient,
    [CUSTOMER_CLIENT]: customerClient,
  },
});
