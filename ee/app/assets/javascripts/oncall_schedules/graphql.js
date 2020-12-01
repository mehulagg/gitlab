import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';

Vue.use(VueApollo);

const resolvers = {};

export default new VueApollo({
  defaultClient: createDefaultClient(resolvers, {
    cacheConfig: {},
    assumeImmutableResults: true,
  }),
});
