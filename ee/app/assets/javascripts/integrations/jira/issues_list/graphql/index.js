import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import jiraIssues from './resolvers/jira_issues';

Vue.use(VueApollo);

const resolvers = {
  Query: {
    jiraIssues,
  },
};

const defaultClient = createDefaultClient(resolvers, { assumeImmutableResults: true });

export default new VueApollo({
  defaultClient,
});
