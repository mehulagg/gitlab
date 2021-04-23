import Vue from 'vue';
import App from 'ee/subscriptions/buy_minutes/components/app.vue';
import stateQuery from 'ee/subscriptions/graphql/queries/state.query.graphql';
import { STEPS } from 'ee/subscriptions/new/constants';
import { convertObjectPropsToCamelCase, parseBoolean } from '~/lib/utils/common_utils';
import apolloProvider from './graphql';

const arrayToGraphqlArray = (arr, typename) =>
  Array.from(arr, (item) =>
    Object.assign(convertObjectPropsToCamelCase(item, { deep: true }), { __typename: typename }),
  );

const writeInitialDataToApolloProvider = (dataset) => {
  const { groupData, newUser, setupForCompany, fullName, planId } = dataset;
  // eslint-disable-next-line @gitlab/require-i18n-strings
  const namespaces = arrayToGraphqlArray(JSON.parse(groupData), 'Namespace');
  const isNewUser = parseBoolean(newUser);
  const isSetupForCompany = parseBoolean(setupForCompany) || !isNewUser;

  apolloProvider.clients.defaultClient.cache.writeQuery({
    query: stateQuery,
    data: {
      state: {
        isNewUser,
        isSetupForCompany,
        namespaces,
        fullName,
        subscription: {
          planId,
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

  writeInitialDataToApolloProvider(el.dataset);

  return new Vue({
    el,
    apolloProvider,
    render(createElement) {
      return createElement(App);
    },
  });
};
