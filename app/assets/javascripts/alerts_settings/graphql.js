import Vue from 'vue';
import produce from 'immer';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import getCurrentIntegrationQuery from './graphql/queries/get_current_integration.query.graphql';
import { typeSet } from './constants';
import mockedCustomMapping from './mocks/parsedMapping.json';

Vue.use(VueApollo);

const resolvers = {
  Mutation: {
    updateCurrentIntegration: (
      _,
      { id = null, name, active, token, type, url, apiUrl },
      { cache },
    ) => {
      const sourceData = cache.readQuery({ query: getCurrentIntegrationQuery });
      const data = produce(sourceData, (draftData) => {
        if (id === null) {
          // eslint-disable-next-line no-param-reassign
          draftData.currentIntegration = null;
        } else {
          // eslint-disable-next-line no-param-reassign
          draftData.currentIntegration = {
            id,
            name,
            active,
            token,
            type,
            url,
            apiUrl,
          };

          if (type === typeSet.http && gon?.features?.multipleHttpIntegrationsCustomMapping) {
            // eslint-disable-next-line no-param-reassign
            draftData.currentIntegration.samplePayload = mockedCustomMapping.samplePayload.body;
          }
        }
      });
      cache.writeQuery({ query: getCurrentIntegrationQuery, data });
    },
  },
};

export default new VueApollo({
  defaultClient: createDefaultClient(resolvers, {
    cacheConfig: {},
    assumeImmutableResults: true,
  }),
});
