import { IntrospectionFragmentMatcher } from 'apollo-cache-inmemory';
import Axios from 'axios';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import introspectionQueryResultData from './fragmentTypes.json';

Vue.use(VueApollo);

const getExternalIssueLinkNode = ({ references: { relative: id }, web_url: webUrl }) => ({
  __typename: 'VulnerabilityExternalIssueLink',
  externalIssue: {
    __typename: 'ExternalIssue',
    externalTracker: 'jira',
    title: 'jira',
    relativeReference: id,
    webUrl,
  },
});

const resolvers = {
  Vulnerability: {
    externalIssueLinks: (
      { id: vulnerabilityId, project: { webUrl } = {} },
      { includeExternalIssueLinks },
    ) => {
      if (!includeExternalIssueLinks) {
        return {
          __typename: 'VulnerabilityExternalIssueLinkConnection',
          nodes: [],
        };
      }

      const [id] = vulnerabilityId.split('/').slice(-1);
      return Axios.get(`${webUrl}/-/integrations/jira/issues.json?vulnerability_ids[]=${id}`)
        .then(({ data }) => {
          return {
            __typename: 'VulnerabilityExternalIssueLinkConnection',
            nodes: data.map(getExternalIssueLinkNode),
          };
        })
        .catch(() => ({
          __typename: 'VulnerabilityExternalIssueLinkConnection',
          nodes: [],
        }));
    },
  },
};

// We create a fragment matcher so that we can create a fragment from an interface
// Without this, Apollo throws a heuristic fragment matcher warning
const fragmentMatcher = new IntrospectionFragmentMatcher({
  introspectionQueryResultData,
});

const defaultClient = createDefaultClient(resolvers, {
  cacheConfig: {
    fragmentMatcher,
  },
  assumeImmutableResults: true,
});

export default new VueApollo({
  defaultClient,
});
