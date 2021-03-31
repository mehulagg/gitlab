import Vue from 'vue';
import ensureData from '~/ensure_data';
import { parseBoolean, convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import App from './components/app.vue';
import apolloProvider from './graphql';
import setStateQuery from './graphql/queries/seed.query.graphql';
import { parseData } from './utils';

const arrayToGraphqlArray = (arr, typename) =>
  Array.from(arr, (item) =>
    Object.assign(convertObjectPropsToCamelCase(item, { deep: true }), { __typename: typename }),
  );

const writeInitialDataToApolloProvider = (dataset) => {
  const { newUser, setupForCompany } = dataset;

  apolloProvider.clients.defaultClient.cache.writeQuery({
    query: setStateQuery,
    data: {
      state: {
        // eslint-disable-next-line @gitlab/require-i18n-strings
        plans: arrayToGraphqlArray(JSON.parse(dataset.ciMinutesPlans), 'Plan'),
        // eslint-disable-next-line @gitlab/require-i18n-strings
        namespaces: arrayToGraphqlArray(JSON.parse(dataset.groupData), 'Namespace'),
        isNewUser: parseBoolean(newUser),
        setupForCompany: parseBoolean(setupForCompany),
        countries: [],
        customer: {
          country: null,
          address1: null,
          address2: null,
          city: null,
          state: null,
          zipCode: null,
          company: null,
          paymentMethodId: null,
          // eslint-disable-next-line @gitlab/require-i18n-strings
          __typename: 'Customer',
        },
        subscription: {
          planId: '',
          paymentMethodId: null,
          products: {
            main: {
              quantity: 1,
              // eslint-disable-next-line @gitlab/require-i18n-strings
              __typename: 'MainProduct',
            },
            // eslint-disable-next-line @gitlab/require-i18n-strings
            __typename: 'Product',
          },
          namespaceId: 1,
          namespaceName: '1',
          // eslint-disable-next-line @gitlab/require-i18n-strings
          __typename: 'Subscription',
        },
        // eslint-disable-next-line @gitlab/require-i18n-strings
        __typename: 'CheckoutState',
      },
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
