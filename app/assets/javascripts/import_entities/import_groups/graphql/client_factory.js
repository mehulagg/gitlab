import { defaultDataIdFromObject } from 'apollo-cache-inmemory';
import produce from 'immer';
import axios from '~/lib/utils/axios_utils';
import createDefaultClient from '~/lib/graphql';
import { STATUSES } from '../../constants';

import { clientTypenames } from './client_typenames';
import ImportSourceGroupFragment from './fragments/bulk_import_source_group_item.fragment.graphql';
import availableNamespacesQuery from './queries/available_namespaces.query.graphql';

function extractTypeConditionFromFragment(fragment) {
  return fragment.definitions[0]?.typeCondition.name.value;
}

function getGroupId(id) {
  return defaultDataIdFromObject({
    __typename: extractTypeConditionFromFragment(ImportSourceGroupFragment),
    id,
  });
}

function findSourceGroupById({ id, cache }) {
  const cacheId = getGroupId(id);
  return cache.readFragment({ fragment: ImportSourceGroupFragment, id: cacheId });
}

function updateSourceGroup({ group, cache }, fn) {
  cache.writeFragment({
    fragment: ImportSourceGroupFragment,
    id: getGroupId(group.id),
    data: produce(group, fn),
  });
}

function updateSourceGroupById({ id, cache }, fn) {
  const group = findSourceGroupById({ id, cache });
  updateSourceGroup({ group, cache }, fn);
}

function setImportStatus({ group, cache }, status) {
  updateSourceGroup({ group, cache }, sourceGroup => {
    // eslint-disable-next-line no-param-reassign
    sourceGroup.status = status;
  });
}

export function createResolvers({ endpoints }) {
  return {
    Query: {
      async bulkImportSourceGroups(_, __, { client }) {
        const {
          data: { availableNamespaces },
        } = await client.query({ query: availableNamespacesQuery });

        return axios.get(endpoints.status).then(({ data }) =>
          data.importable_data.map(group => ({
            __typename: clientTypenames.BulkImportSourceGroup,
            ...group,
            status: STATUSES.NONE,
            import_target: {
              new_name: group.full_path,
              target_namespace: availableNamespaces[0].full_path,
            },
          })),
        );
      },

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

      async importGroup(_, { sourceGroupId }, { cache }) {
        const group = findSourceGroupById({ id: sourceGroupId, cache });
        setImportStatus({ group, cache }, STATUSES.SCHEDULING);
        try {
          await axios.post('/import/bulk_imports', [
            {
              source_type: 'group_entity',
              source_full_path: group.full_path,
              destination_namespace: group.import_target.target_namespace,
              destination_name: group.import_target.new_name,
            },
          ]);
          setImportStatus({ group, cache }, STATUSES.SCHEDULED);
        } catch (e) {
          setImportStatus({ group, cache }, STATUSES.NONE);
        }
      },
    },
  };
}

export const createApolloClient = ({ endpoints }) =>
  createDefaultClient(createResolvers({ endpoints }), { assumeImmutableResults: true });
