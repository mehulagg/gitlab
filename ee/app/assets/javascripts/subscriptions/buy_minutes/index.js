import Vue from 'vue';
import ensureData from '~/ensure_data';
import { parseBoolean } from '~/lib/utils/common_utils';
import App from './components/app.vue';
import apolloProvider from './graphql';
import seedQuery from './graphql/queries/seed.query.graphql';
import { parseData } from './utils';

const arrayToGraphqlArray = (arr, typename) =>
  Array.from(arr, (item) => Object.assign(item, { __typename: typename }));

const writeInitialDataToApolloProvider = (dataset) => {
  const { newUser, fullName, setupForCompany } = dataset;

  apolloProvider.clients.defaultClient.cache.writeQuery({
    query: seedQuery,
    data: {
      // eslint-disable-next-line @gitlab/require-i18n-strings
      plans: arrayToGraphqlArray(JSON.parse(dataset.ciMinutesPlans), 'Plan'),
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

  const ExtendedApp = ensureData(App, {
    parseData,
    data: el.dataset,
  });

  writeInitialDataToApolloProvider(el.dataset);

  return new Vue({
    el,
    apolloProvider,
    render(createElement) {
      return createElement(ExtendedApp);
    },
  });
};
