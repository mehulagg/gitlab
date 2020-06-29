<script>
import { GlTabs, GlTab, GlLoadingIcon, GlSearchBoxByType } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import createFlash from '~/flash';
import ForkGroupsListItem from './fork_groups_list_item.vue';

export default {
  components: {
    GlTabs,
    GlTab,
    GlLoadingIcon,
    GlSearchBoxByType,
    ForkGroupsListItem,
  },
  props: {
    hasReachedProjectLimit: {
      type: Boolean,
      required: true,
    },
    endpoint: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      namespaces: null,
      filter: '',
    };
  },
  computed: {
    searchPlaceholder() {
      return __('Search by name');
    },

    filteredNamespaces() {
      return this.namespaces.filter(n => n.name.toLowerCase().includes(this.filter.toLowerCase()));
    },
  },

  mounted() {
    this.loadGroups();
  },

  methods: {
    loadGroups() {
      axios
        .get(this.endpoint)
        .then(response => {
          this.namespaces = response.data.namespaces;
        })
        .catch(() => createFlash(__('There was a problem fetching groups.')));
    },
  },
};
</script>
<template>
  <gl-tabs theme="indigo" class="fork-groups">
    <gl-tab title="Groups and subgroups">
      <gl-loading-icon v-if="!namespaces" size="md" class="gl-mt-3" />
      <template v-else-if="namespaces.length === 0">
        <div class="gl-text-center">
          <h5>{{ __('No available groups to fork the project.') }}</h5>
          <p class="gl-mt-5">
            {{ __('You must have permission to create a project in a group before forking.') }}
          </p>
        </div>
      </template>
      <div v-else-if="filteredNamespaces.length === 0" class="gl-text-center gl-mt-3">
        {{ s__('GroupsTree|No groups matched your search') }}
      </div>
      <ul v-else class="groups-list group-list-tree">
        <fork-groups-list-item
          v-for="(namespace, index) in filteredNamespaces"
          :key="index"
          :group="namespace"
          :has-reached-project-limit="hasReachedProjectLimit"
        />
      </ul>
    </gl-tab>
    <template #tabs-end>
      <gl-search-box-by-type
        v-if="namespaces && namespaces.length"
        v-model="filter"
        :placeholder="searchPlaceholder"
        class="gl-align-self-center gl-ml-auto filtered-search-dropdown"
      />
    </template>
  </gl-tabs>
</template>
