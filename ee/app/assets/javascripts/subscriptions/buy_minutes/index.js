import Vue from 'vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import App from './components/app.vue';
import apolloProvider from './graphql';
import seedQuery from './graphql/queries/seed.query.graphql';

const arrayToGraphqlArray = (arr, typename) =>
  Array.from(arr, (item) => Object.assign(item, { __typename: typename }));

const writeInitialDataToApolloProvider = (dataset) => {
  const { newUser, fullName, setupForCompany } = dataset;

  apolloProvider.clients.defaultClient.cache.writeQuery({
    query: seedQuery,
    data: {
      // eslint-disable-next-line @gitlab/require-i18n-strings
      namespaces: arrayToGraphqlArray(JSON.parse(dataset.groupData), 'Namespace'),
      newUser: parseBoolean(newUser),
      setupForCompany: parseBoolean(setupForCompany),
      fullName,
    },
  });
};

export default (el) => {
  if (!el) {
    return null;
  }

  writeInitialDataToApolloProvider(el.dataset);

  return new Vue({
    el,
    apolloProvider,
    render(createElement) {
      return createElement(App);
    },
  });
};
