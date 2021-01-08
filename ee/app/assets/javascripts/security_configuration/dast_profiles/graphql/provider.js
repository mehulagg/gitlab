import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';

Vue.use(VueApollo);

/* eslint-disable @gitlab/require-i18n-strings */
const resolvers = {
  Query: {
    project: () => ({
      __typename: 'Project',
      savedScans: {
        edges: [
          {
            node: {
              id: 1,
              name: 'My daily scan',
              description: 'Tests for SQL injection',
              dastSiteProfile: {
                id: 1,
                targetUrl: 'http://example.com',
                __typename: 'DastSiteProfile',
              },
              dastScannerProfile: {
                id: 1,
                scanType: 'ACTIVE',
                __typename: 'DastScannerProfile',
              },
              editPath: '/on_demand_scans/1/edit',
              __typename: 'DastSavedScan',
            },
            __typename: 'DastSavedScanEdge',
          },
        ],
        __typename: 'DastSavedScanConnection',
      },
    }),
  },
};
/* eslint-enable @gitlab/require-i18n-strings */

export default new VueApollo({
  defaultClient: createDefaultClient(resolvers, {
    assumeImmutableResults: true,
  }),
});
