import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';

Vue.use(VueApollo);

const resolvers = {
  Mutation: {
    configureApiFuzzing: () => {
      return {
        configurationYaml: 'yaml',
        status: 'OK',
        gitlabCiYamlEditUrl: '/edit/yaml',
        __typename: 'ApiFuzzingConfiguration',
      };
    },
  },
};

export const apolloProvider = new VueApollo({ defaultClient: createDefaultClient(resolvers) });
