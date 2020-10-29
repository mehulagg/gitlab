<script>
import { ApolloMutation, ApolloQuery } from 'vue-apollo';
import { GlButton, GlLoadingIcon } from '@gitlab/ui';
import { n__, __, sprintf } from '~/locale';
import bulkImportSourceGroupsQuery from '../graphql/queries/bulk_import_source_groups.query.graphql';
import setTargetNamespaceMutation from '../graphql/mutations/set_target_namespace.mutation.graphql';
import setNewNameMutation from '../graphql/mutations/set_new_name.mutation.graphql';
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

  methods: {
    ...mapApolloMutations({
      setTargetNamespace: setTargetNamespaceMutation,
      setNewName: setNewNameMutation,
    }),
  },
};
</script>

<template>
  <div>
    <p class="light text-nowrap mt-2">
      {{ s__('ImportGroups|Select the repositories you want to import') }}
    </p>
    <apollo-query
      #default="{ isLoading, result: { data: groupsQuery } }"
      :query="$options.queries.bulkImportSourceGroups"
    >
      <gl-loading-icon
        v-if="isLoading"
        class="js-loading-button-icon import-projects-loading-icon"
        size="md"
      />
      <div v-else-if="groupsQuery.bulkImportSourceGroups.length" class="table-responsive">
        <table>
          <thead>
            <th>{{ __('From source group') }}</th>
            <th>{{ __('To new group') }}</th>
            <th>{{ __('Status') }}</th>
            <th></th>
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
              />
            </template>
          </tbody>
        </table>

        {{ groupsQuery.availableNamespaces }}
      </div>
    </apollo-query>
  </div>
</template>
