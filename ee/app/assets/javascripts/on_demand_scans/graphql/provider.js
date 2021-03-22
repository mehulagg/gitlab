import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { resolvers } from 'ee/security_configuration/dast_profiles/graphql/provider';
import createDefaultClient from '~/lib/graphql';

Vue.use(VueApollo);

export default new VueApollo({
  defaultClient: createDefaultClient(resolvers),
});
