/* eslint-disable @gitlab/require-i18n-strings */
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { range } from 'lodash';
import createDefaultClient from '~/lib/graphql';

Vue.use(VueApollo);

// NOTE: We currently mock some fake DAST scans while the feature is feature-flagged and the
// backend is being worked on.
//  This will be cleaned up as part of https://gitlab.com/gitlab-org/gitlab/-/issues/295248.
let id = 0;
const generateFakeDastScan = () => {
  id += 1;
  return {
    node: {
      id,
      name: `My daily scan #${id}`,
      description: 'Tests for SQL injection',
      dastSiteProfile: {
        id,
        targetUrl: 'http://example.com ',
        __typename: 'DastSiteProfile',
      },
      dastScannerProfile: {
        id,
        scanType: Math.random() < 0.5 ? 'PASSIVE' : 'ACTIVE',
        __typename: 'DastScannerProfile',
      },
      editPath: '/on_demand_scans/1/edit',
      __typename: 'DastSavedScan',
    },
    __typename: 'DastSavedScanEdge',
  };
};

const resolvers = {
  Query: {
    project: () => ({
      __typename: 'Project',
      savedScans: {
        pageInfo: {
          hasNextPage: true,
          hasPreviousPage: false,
          startCursor: 'startCursor',
          endCursor: 'endCursor',
          __typename: 'PageInfo',
        },
        edges: range(10).map(generateFakeDastScan),
        __typename: 'DastSavedScanConnection',
      },
    }),
  },
};

export default new VueApollo({
  defaultClient: createDefaultClient(resolvers, {
    assumeImmutableResults: true,
  }),
});
