import { parseBoolean } from '~/lib/utils/common_utils';
import seedQuery from './graphql/queries/seed.query.graphql';

function arrayToGraphqlArray(arr, typename) {
  return Array.from(arr, (item) => Object.assign(item, { __typename: typename }));
}

export function writeInitialDataToApolloProvider(apolloProvider, dataset) {
  const { newUser, fullName, setupForCompany, groupData } = dataset;

  apolloProvider.clients.defaultClient.cache.writeQuery({
    query: seedQuery,
    data: {
      // eslint-disable-next-line @gitlab/require-i18n-strings
      namespaces: arrayToGraphqlArray(JSON.parse(groupData), 'Namespace'),
      newUser: parseBoolean(newUser),
      setupForCompany: parseBoolean(setupForCompany),
      fullName,
    },
  });
}
