import axios from '~/lib/utils/axios_utils';
import createDefaultClient from '~/lib/graphql';
import { STATUSES } from '../../constants';

import { clientTypenames } from './client_typenames';
import availableNamespacesQuery from './queries/available_namespaces.query.graphql';
import { SourceGroupsManager } from './services/source_groups_manager';
import { StatusPoller } from './services/status_poller';

export function createResolvers({ endpoints }) {
  let statusPoller;

  return {
    Query: {
      async bulkImportSourceGroups(_, __, { client }) {
        const {
          data: { availableNamespaces },
        } = await client.query({ query: availableNamespacesQuery });

        statusPoller = new StatusPoller({ client });

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
        new SourceGroupsManager({ cache }).updateById(sourceGroupId, sourceGroup => {
          // eslint-disable-next-line no-param-reassign
          sourceGroup.import_target.target_namespace = targetNamespace;
        });
      },

      setNewName(_, { newName, sourceGroupId }, { cache }) {
        new SourceGroupsManager({ cache }).updateById(sourceGroupId, sourceGroup => {
          // eslint-disable-next-line no-param-reassign
          sourceGroup.import_target.new_name = newName;
        });
      },

      async importGroup(_, { sourceGroupId }, { cache }) {
        const groupManager = new SourceGroupsManager({ cache });
        const group = groupManager.findById(sourceGroupId);
        groupManager.setImportStatus({ group, status: STATUSES.SCHEDULING });
        try {
          await axios.post('/import/bulk_imports', {
            bulk_import: [
              {
                source_type: 'group_entity',
                source_full_path: group.full_path,
                destination_namespace: group.import_target.target_namespace,
                destination_name: group.import_target.new_name,
              },
            ],
          });
          groupManager.setImportStatus({ group, status: STATUSES.STARTED });
          statusPoller.checkCurrentImports();
        } catch (e) {
          groupManager.setImportStatus({ group, status: STATUSES.NONE });
        }
      },
    },
  };
}

export const createApolloClient = ({ endpoints }) =>
  createDefaultClient(createResolvers({ endpoints }), { assumeImmutableResults: true });
