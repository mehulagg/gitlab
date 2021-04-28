import { STEPS } from 'ee/subscriptions/constants';
import stateQuery from 'ee/subscriptions/graphql/queries/state.query.graphql';
import { convertObjectPropsToCamelCase, parseBoolean } from '~/lib/utils/common_utils';

function arrayToGraphqlArray(arr, typename) {
  return Array.from(arr, (item) => {
    return Object.assign(convertObjectPropsToCamelCase(item, { deep: true }), {
      __typename: typename,
    });
  });
}

export function writeInitialDataToApolloCache(apolloProvider, dataset) {
  const { groupData, newUser, setupForCompany, fullName, planId = null } = dataset;
  // eslint-disable-next-line @gitlab/require-i18n-strings
  const namespaces = arrayToGraphqlArray(JSON.parse(groupData), 'Namespace');
  const isNewUser = parseBoolean(newUser);
  const isSetupForCompany = parseBoolean(setupForCompany) || !isNewUser;

  apolloProvider.clients.defaultClient.cache.writeQuery({
    query: stateQuery,
    data: {
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
      activeStep: STEPS[0],
      stepList: STEPS,
    },
  });
}
