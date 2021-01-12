import { defaultDataIdFromObject } from 'apollo-cache-inmemory';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import TerraformList from './components/terraform_list.vue';
import createDefaultClient from '~/lib/graphql';
import TerraformState from './graphql/fragments/state.fragment.graphql';

Vue.use(VueApollo);

export default () => {
  const el = document.querySelector('#js-terraform-list');

  if (!el) {
    return null;
  }

  const resolvers = {
    TerraformState: {
      _showDetails: (state) => {
        // eslint-disable-next-line no-underscore-dangle
        return state._showDetails || false;
      },
      errorMessages: (state) => {
        return state.errorMessages || [];
      },
      loadingActions: (state) => {
        return state.loadingActions || false;
      },
    },
    Mutation: {
      addDataToTerraformState: (_, { terraformState }, { client }) => {
        const previousTerraformState = client.readFragment({
          id: terraformState.id,
          fragment: TerraformState,
          // eslint-disable-next-line @gitlab/require-i18n-strings
          fragmentName: 'State',
        });

        if (previousTerraformState) {
          client.writeFragment({
            id: previousTerraformState.id,
            fragment: TerraformState,
            // eslint-disable-next-line @gitlab/require-i18n-strings
            fragmentName: 'State',
            data: {
              ...previousTerraformState,
              // eslint-disable-next-line no-underscore-dangle
              _showDetails: terraformState._showDetails,
              errorMessages: terraformState.errorMessages,
              loadingActions: terraformState.loadingActions,
            },
          });
        }
      },
    },
  };

  const config = {
    cacheConfig: {
      dataIdFromObject: (object) => {
        return object.id || defaultDataIdFromObject(object);
      },
    },
  };

  const defaultClient = createDefaultClient(resolvers, config);

  const { emptyStateImage, projectPath } = el.dataset;

  return new Vue({
    el,
    apolloProvider: new VueApollo({ defaultClient }),
    render(createElement) {
      return createElement(TerraformList, {
        props: {
          emptyStateImage,
          projectPath,
          terraformAdmin: el.hasAttribute('data-terraform-admin'),
        },
      });
    },
  });
};
