import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';

Vue.use(VueApollo);

export default new VueApollo({
  defaultClient: createDefaultClient(
    {},
    {
      baseUrl: 'http://localhost:4000',
    },
  ),
});

// export default new VueApollo({
//   defaultClient: createDefaultClient(),
// });
