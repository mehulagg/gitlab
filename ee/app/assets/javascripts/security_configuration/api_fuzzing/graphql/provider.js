import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';

Vue.use(VueApollo);

const resolvers = {
  Mutation: {
    createApiFuzzingCiConfiguration: () => {
      return {
        configurationYaml: 'yaml',
        gitlabCiYamlEditUrl: '/edit/yaml',
        errors: [],
        __typename: 'ApiFuzzingConfiguration',
      };
    },
  },
};

export const apolloProvider = new VueApollo({ defaultClient: createDefaultClient(resolvers) });
