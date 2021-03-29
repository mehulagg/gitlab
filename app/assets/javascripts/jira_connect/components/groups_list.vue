<script>
import { GlLoadingIcon, GlPagination, GlAlert, GlSearchBoxByType } from '@gitlab/ui';
import { debounce } from 'lodash';
import { fetchGroups } from '~/jira_connect/api';
import { defaultPerPage } from '~/jira_connect/constants';
import { parseIntPagination, normalizeHeaders } from '~/lib/utils/common_utils';
import { s__ } from '~/locale';
import GroupsListItem from './groups_list_item.vue';

export default {
  components: {
    GlLoadingIcon,
    GlPagination,
    GlAlert,
    GlSearchBoxByType,
    GroupsListItem,
  },
  inject: {
    groupsPath: {
      default: '',
    },
  },
  data() {
    return {
      groups: [],
      isLoading: false,
      page: 1,
      perPage: defaultPerPage,
      totalItems: 0,
      errorMessage: null,
    };
  },
  mounted() {
    this.loadGroups();
  },
  methods: {
    loadGroups({ filter } = {}) {
      this.isLoading = true;

      fetchGroups(this.groupsPath, {
        page: this.page,
        perPage: this.perPage,
        filter,
      })
        .then((response) => {
          const { page, total } = parseIntPagination(normalizeHeaders(response.headers));
          this.page = page;
          this.totalItems = total;
          this.groups = response.data;
        })
        .catch(() => {
          this.errorMessage = s__('Integrations|Failed to load namespaces. Please try again.');
        })
        .finally(() => {
          this.isLoading = false;
        });
    },
    debouncedGroupsSearch: debounce(function groupsSearchOnInput(filter) {
      this.loadGroups({ filter });
    }, 500),
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="errorMessage" class="gl-mb-6" variant="danger" @dismiss="errorMessage = null">
      {{ errorMessage }}
    </gl-alert>

    <gl-search-box-by-type :placeholder="__('Search by name')" @input="debouncedGroupsSearch" />

    <gl-loading-icon v-if="isLoading" size="md" />
    <div v-else-if="groups.length === 0" class="gl-text-center">
      <h5>{{ s__('Integrations|No available namespaces.') }}</h5>
      <p class="gl-mt-5">
        {{ s__('Integrations|You must have owner or maintainer permissions to link namespaces.') }}
      </p>
    </div>
    <ul v-else class="gl-list-style-none gl-pl-0">
      <groups-list-item
        v-for="group in groups"
        :key="group.id"
        :group="group"
        @error="errorMessage = $event"
      />
    </ul>

    <div class="gl-display-flex gl-justify-content-center gl-mt-5">
      <gl-pagination
        v-if="totalItems > perPage && groups.length > 0"
        v-model="page"
        class="gl-mb-0"
        :per-page="perPage"
        :total-items="totalItems"
        @input="loadGroups"
      />
    </div>
  </div>
</template>
