<script>
import { ApolloMutation, ApolloQuery } from 'vue-apollo';
import { GlButton, GlLoadingIcon } from '@gitlab/ui';
import { n__, __, sprintf } from '~/locale';
import bulkImportSourceGroupsQuery from '../graphql/queries/bulk_import_source_groups.graphql';
import ImportTableRow from './import_table_row.vue';

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
    // availableNamespaces() {
    //   const serializedNamespaces = this.namespaces.map(({ fullPath }) => ({
    //     id: fullPath,
    //     text: fullPath,
    //   }));
    //   return [
    //     { text: __('Groups'), children: serializedNamespaces },
    //     {
    //       text: __('Users'),
    //       children: [{ id: this.defaultTargetNamespace, text: this.defaultTargetNamespace }],
    //     },
    //   ];
    // },GitLab
    // },
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
              />
            </template>
          </tbody>
        </table>

        {{ groupsQuery.availableNamespaces }}
      </div>
    </apollo-query>
  </div>
</template>
