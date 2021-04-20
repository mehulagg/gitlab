import Vue from 'vue';
import { STEPS } from 'ee/subscriptions/new/constants';
import ensureData from '~/ensure_data';
import { convertObjectPropsToCamelCase, parseBoolean } from '~/lib/utils/common_utils';
import App from '../components/app.vue';
import stateQuery from '../graphql/queries/state.query.graphql';
import apolloProvider from './graphql';
import { parseData } from './utils';

const arrayToGraphqlArray = (arr, typename) =>
  Array.from(arr, (item) =>
    Object.assign(convertObjectPropsToCamelCase(item, { deep: true }), { __typename: typename }),
  );

const writeInitialDataToApolloProvider = (dataset) => {
  // eslint-disable-next-line @gitlab/require-i18n-strings
  const plans = arrayToGraphqlArray(JSON.parse(dataset.ciMinutesPlans), 'Plan');
  // eslint-disable-next-line @gitlab/require-i18n-strings
  const namespaces = arrayToGraphqlArray(JSON.parse(dataset.groupData), 'Namespace');
  const isNewUser = parseBoolean(dataset.newUser);
  const isSetupForCompany = parseBoolean(dataset.setupForCompany) || !isNewUser;

  apolloProvider.clients.defaultClient.cache.writeQuery({
    query: stateQuery,
    data: {
      state: {
        isNewUser,
        isSetupForCompany,
        plans,
        namespaces,
        fullName: dataset.fullName,
        subscription: {
          planId: plans[0].code,
          paymentMethodId: null,
          quantity: 1,
          namespaceId: null,
          // eslint-disable-next-line @gitlab/require-i18n-strings
          __typename: 'Subscription',
        },
        customer: {
          country: null,
          address1: null,
          address2: null,
          city: null,
          state: null,
          zipCode: null,
          company: null,
          // eslint-disable-next-line @gitlab/require-i18n-strings
          __typename: 'Customer',
        },
        // eslint-disable-next-line @gitlab/require-i18n-strings
        __typename: 'State',
      },
      activeStep: STEPS[0],
      stepList: STEPS,
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
