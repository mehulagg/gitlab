import { defaultDataIdFromObject } from 'apollo-cache-inmemory';
import produce from 'immer';
import axios from '~/lib/utils/axios_utils';
import createDefaultClient from '~/lib/graphql';
import { STATUSES } from '../../constants';

import { clientTypenames } from './client_typenames';
import ImportSourceGroupFragment from './fragments/bulk_import_source_group_item.fragment.graphql';

// import typeDefs from './graphql/typedefs.graphql';

function updateSourceGroupById({ id, cache }, fn) {
  const cacheId = defaultDataIdFromObject({
    __typename: clientTypenames.BulkImportSourceGroup,
    id,
  });
  const source = cache.readFragment({ fragment: ImportSourceGroupFragment, id: cacheId });
  cache.writeFragment({
    fragment: ImportSourceGroupFragment,
    id: cacheId,
    data: produce(source, fn),
  });
}

export function createResolvers({ endpoints }) {
  return {
    Query: {
      bulkImportSourceGroups: () =>
        axios.get(endpoints.status).then(({ data }) =>
          data.importable_data.map(group => ({
            __typename: clientTypenames.BulkImportSourceGroup,
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
            __typename: clientTypenames.AvailableNamespace,
            ...namespace,
          })),
        ),
    },
    Mutation: {
      setTargetNamespace(_, { targetNamespace, sourceGroupId }, { cache }) {
        updateSourceGroupById({ id: sourceGroupId, cache }, sourceGroup => {
          // eslint-disable-next-line no-param-reassign
          sourceGroup.import_target.target_namespace = targetNamespace;
        });
      },

      setNewName(_, { newName, sourceGroupId }, { cache }) {
        updateSourceGroupById({ id: sourceGroupId, cache }, sourceGroup => {
          // eslint-disable-next-line no-param-reassign
          sourceGroup.import_target.new_name = newName;
        });
      },
    },
  };
}

export const createApolloClient = ({ endpoints }) =>
  createDefaultClient(createResolvers({ endpoints }), { assumeImmutableResults: true });
