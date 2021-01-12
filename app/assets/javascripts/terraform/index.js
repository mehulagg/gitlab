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
        // return state._showDetails <- This will error
        return state.name;
      },
    },
    Mutation: {
      addDataToTerraformState: (_, { stateID }, { client }) => {
        const terraformState = client.readFragment({
          id: stateID,
          fragment: TerraformState,
          // eslint-disable-next-line @gitlab/require-i18n-strings
          fragmentName: 'State',
        });

        // eslint-disable-next-line @gitlab/require-i18n-strings
        terraformState.name = 'Name can be changed because it is part of the fragment!';

        // eslint-disable-next-line no-underscore-dangle
        terraformState._showDetails = true;
        // This field is ignored because terraformState._showDetails() is a function

        // eslint-disable-next-line @gitlab/require-i18n-strings
        terraformState.errorMessages = ['Error Message!'];
        // This field will also be igored

        client.writeFragment({
          id: stateID,
          fragment: TerraformState,
          // eslint-disable-next-line @gitlab/require-i18n-strings
          fragmentName: 'State',
          data: {
            ...terraformState,
          },
        });

        return null;
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
