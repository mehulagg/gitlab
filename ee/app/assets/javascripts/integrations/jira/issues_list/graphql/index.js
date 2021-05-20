import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';

Vue.use(VueApollo);

const resolvers = {
  Query: {
    jiraIssues(_, { projectPath, search }) {
      return {};
    },
  },
};

const defaultClient = createDefaultClient(resolvers);

export default new VueApollo({
  defaultClient,
});
