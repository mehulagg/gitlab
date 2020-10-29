import axios from '~/lib/utils/axios_utils';
import createDefaultClient from '~/lib/graphql';
import { STATUSES } from '../../constants';
// import typeDefs from './graphql/typedefs.graphql';

export function createResolvers({ endpoints }) {
  return {
    Query: {
      bulkImportSourceGroups: () =>
        axios.get(endpoints.status).then(({ data }) =>
          data.importable_data.map(group => ({
            __typename: 'ClientBulkImportSourceGroup',
            ...group,
            status: STATUSES.NONE,
            import_target: {
              new_name: group.path,
              target_namespace: '',
            },
          })),
        ),

      availableNamespaces: () =>
        axios.get(endpoints.availableNamespaces).then(({ data }) =>
          data.map(namespace => ({
            __typename: 'ClientAvailableNamespace',
            ...namespace,
          })),
        ),
    },
  };
}

export const createApolloClient = ({ endpoints }) =>
  createDefaultClient(createResolvers({ endpoints }), { assumeImmutableResults: true });
