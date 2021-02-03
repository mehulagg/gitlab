import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { IntrospectionFragmentMatcher } from 'apollo-cache-inmemory';
import createDefaultClient from '~/lib/graphql';
import introspectionQueryResultData from './fragmentTypes.json';

Vue.use(VueApollo);

// We create a fragment matcher so that we can create a fragment from an interface
// Without this, Apollo throws a heuristic fragment matcher warning
const fragmentMatcher = new IntrospectionFragmentMatcher({
  introspectionQueryResultData,
});

// -- start -- temporary local resolver @TODO Remove me
const resolvers = {
  Vulnerability: {
    externalIssueLinks: () => {
      return {
        __typename: 'VulnerabilityExternalIssueLinkConnection',
        nodes: [
          {
            __typename: 'VulnerabilityExternalIssueLink',
            externalIssue: {
              __typename: 'ExternalIssue',
              externalTracker: 'jira',
              webUrl: 'https://mparuszewski-gitlab.atlassian.net/browse/GV-11',
            },
            linkType: 'CREATED',
          },
        ],
      };
    },
  },
};
// -- end -- temporary local resolver @TODO Remove me

const defaultClient = createDefaultClient(resolvers, {
  cacheConfig: {
    fragmentMatcher,
  },
  assumeImmutableResults: true,
});

export default new VueApollo({
  defaultClient,
});
