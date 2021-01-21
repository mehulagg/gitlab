/* eslint-disable @gitlab/require-i18n-strings */
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';

Vue.use(VueApollo);

// TODO: Remove mocks and @client directive
const resolvers = {
  Query: {
    project: () => {
      return {
        __typename: 'Project',
        apiFuzzingCiConfiguration: {
          __typename: 'ApiFuzzingCiConfiguration',
          scanModes: [1, 2, 3],
          scanProfiles: [
            {
              __typename: 'ScanProfile',
              name: 'Scan profile 1',
              description: 'Yes, this is a scan profile',
              yaml: 'do we really need YAML here?',
            },
          ],
        },
      };
    },
  },
};

export const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(resolvers, {
    assumeImmutableResults: true,
  }),
});
