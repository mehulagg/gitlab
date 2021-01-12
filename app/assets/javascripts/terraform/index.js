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
      addDataToTerraformState: (
        _,
        { errorMessages, loadingActions, stateID, showDetails },
        { client },
      ) => {
        const terraformState = client.readFragment({
          id: stateID,
          fragment: TerraformState,
          // eslint-disable-next-line @gitlab/require-i18n-strings
          fragmentName: 'State',
        });

        if (terraformState) {
          client.writeFragment({
            id: stateID,
            fragment: TerraformState,
            // eslint-disable-next-line @gitlab/require-i18n-strings
            fragmentName: 'State',
            data: {
              ...terraformState,
              _showDetails: showDetails,
              errorMessages,
              loadingActions,
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
