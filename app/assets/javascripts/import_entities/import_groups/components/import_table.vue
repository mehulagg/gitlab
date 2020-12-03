<script>
import { ApolloQuery } from 'vue-apollo';
import { GlLoadingIcon } from '@gitlab/ui';
import bulkImportSourceGroupsQuery from '../graphql/queries/bulk_import_source_groups.query.graphql';
import setTargetNamespaceMutation from '../graphql/mutations/set_target_namespace.mutation.graphql';
import setNewNameMutation from '../graphql/mutations/set_new_name.mutation.graphql';
import importGroupMutation from '../graphql/mutations/import_group.mutation.graphql';
import ImportTableRow from './import_table_row.vue';

const mapApolloMutations = mutations =>
  Object.fromEntries(
    Object.entries(mutations).map(([key, mutation]) => [
      key,
      function mutate(config) {
        return this.$apollo.mutate({
          mutation,
          ...config,
        });
      },
    ]),
  );

export default {
  components: {
    ApolloQuery,
    GlLoadingIcon,
    ImportTableRow,
  },

  queries: {
    bulkImportSourceGroups: bulkImportSourceGroupsQuery,
  },

  computed: {
    link() {
      return 'https://gitlab.com';
    },
  },

  methods: {
    ...mapApolloMutations({
      setTargetNamespace: setTargetNamespaceMutation,
      setNewName: setNewNameMutation,
      importGroup: importGroupMutation,
    }),
  },
};
</script>

<template>
  <div>
    <apollo-query
      #default="{ isLoading, result: { data: groupsQuery } }"
      :query="$options.queries.bulkImportSourceGroups"
    >
      <gl-loading-icon v-if="isLoading" size="md" class="gl-mt-5" />
      <div v-else-if="groupsQuery.bulkImportSourceGroups.length">
        <table class="gl-w-full" style="table-layout: fixed;">
          <thead class="gl-border-solid gl-border-gray-200 gl-border-0 gl-border-b-1">
            <th class="gl-p-4">{{ __('From source group') }}</th>
            <th class="gl-p-4">{{ __('To new group') }}</th>
            <th class="gl-p-4">{{ __('Status') }}</th>
            <th class="gl-p-4 gl-w-12"></th>
          </thead>
          <tbody>
            <template v-for="group in groupsQuery.bulkImportSourceGroups">
              <import-table-row
                :key="group.id"
                :group="group"
                :available-namespaces="groupsQuery.availableNamespaces"
                @update-target-namespace="
                  setTargetNamespace({
                    variables: { sourceGroupId: group.id, targetNamespace: $event },
                  })
                "
                @update-new-name="
                  setNewName({
                    variables: { sourceGroupId: group.id, newName: $event },
                  })
                "
                @import-group="importGroup({ variables: { sourceGroupId: group.id } })"
              />
            </template>
          </tbody>
        </table>
      </div>
    </apollo-query>
  </div>
</template>
