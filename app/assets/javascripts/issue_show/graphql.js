import produce from 'immer';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import getIssueStateQuery from './queries/get_issue_state.query.graphql';

Vue.use(VueApollo);

const resolvers = {
  Mutation: {
    updateIssueState: (_, { issue_type = '' }, { cache }) => {
      const sourceData = cache.readQuery({ query: getIssueStateQuery });
      const data = produce(sourceData, (draftData) => {
        draftData.issueState = { issue_type };
      });
      cache.writeQuery({ query: getIssueStateQuery, data });
    },
  },
};

export default new VueApollo({
  defaultClient: createDefaultClient(resolvers, {
    cacheConfig: {},
    assumeImmutableResults: true,
  }),
});
