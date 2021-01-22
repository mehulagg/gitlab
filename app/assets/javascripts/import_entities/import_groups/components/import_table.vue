<script>
import { GlLoadingIcon, GlSearchBoxByClick } from '@gitlab/ui';
import bulkImportSourceGroupsQuery from '../graphql/queries/bulk_import_source_groups.query.graphql';
import availableNamespacesQuery from '../graphql/queries/available_namespaces.query.graphql';
import setTargetNamespaceMutation from '../graphql/mutations/set_target_namespace.mutation.graphql';
import setNewNameMutation from '../graphql/mutations/set_new_name.mutation.graphql';
import importGroupMutation from '../graphql/mutations/import_group.mutation.graphql';
import ImportTableRow from './import_table_row.vue';
import PaginationLinks from '~/vue_shared/components/pagination_links.vue';

const mapApolloMutations = (mutations) =>
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
    GlLoadingIcon,
    GlSearchBoxByClick,
    ImportTableRow,
    PaginationLinks,
  },

  data() {
    return { page: 1 };
  },

  apollo: {
    bulkImportSourceGroups: {
      query: bulkImportSourceGroupsQuery,
      variables() {
        return { page: this.page };
      },
    },
    availableNamespaces: availableNamespacesQuery,
  },

  methods: {
    setPage(page) {
      this.page = page;
    },

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
    <gl-loading-icon v-if="$apollo.loading" size="md" class="gl-mt-5" />
    <div v-else-if="bulkImportSourceGroups.nodes && bulkImportSourceGroups.nodes.length">
      <table class="gl-w-full">
        <thead class="gl-border-solid gl-border-gray-200 gl-border-0 gl-border-b-1">
          <th class="gl-py-4 import-jobs-from-col">{{ s__('BulkImport|From source group') }}</th>
          <th class="gl-py-4 import-jobs-to-col">{{ s__('BulkImport|To new group') }}</th>
          <th class="gl-py-4 import-jobs-status-col">{{ __('Status') }}</th>
          <th class="gl-py-4 import-jobs-cta-col"></th>
        </thead>
        <tbody>
          <template v-for="group in bulkImportSourceGroups.nodes">
            <import-table-row
              :key="group.id"
              :group="group"
              :available-namespaces="availableNamespaces"
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
      <pagination-links
        :change="setPage"
        :page-info="bulkImportSourceGroups.pageInfo"
        class="gl-flex gl-mt-3"
      />
    </div>
  </div>
</template>
