<script>
import { GlTabs, GlTab, GlLoadingIcon, GlPagination } from '@gitlab/ui';
import { parseIntPagination, normalizeHeaders } from '~/lib/utils/common_utils';
import { fetchGroups } from '~/jira_connect/api';
import { defaultPerPage } from '~/jira_connect/constants';

export default {
  components: {
    GlTabs,
    GlTab,
    GlLoadingIcon,
    GlPagination,
  },
  inject: {
    groupsPath: {
      default: '',
    },
  },
  data() {
    return {
      groups: null,
      isLoading: false,
      page: 1,
      perPage: defaultPerPage,
      totalItems: 0,
    };
  },
  mounted() {
    this.loadGroups();
  },
  methods: {
    loadGroups() {
      this.isLoading = true;

      fetchGroups(this.groupsPath, {
        page: this.page,
        perPage: this.perPage,
      })
        .then((response) => {
          const { page, total } = parseIntPagination(normalizeHeaders(response.headers));
          this.page = page;
          this.totalItems = total;
          this.groups = response.data;
        })
        .catch(() => {})
        .finally(() => {
          this.isLoading = false;
        });
    },
  },
};
</script>

<template>
  <div>
    <gl-tabs>
      <gl-tab :title="__('Groups and subgroups')" class="gl-pt-3">
        <gl-loading-icon v-if="isLoading" size="md" />
        <template v-else-if="groups.length === 0">
          <div class="gl-text-center">
            <div class="h5">{{ s__('Integrations|No available namespaces.') }}</div>
            <p class="gl-mt-5">
              {{
                s__(
                  'Integrations|You must have owner or maintainer permissions to link namespaces.',
                )
              }}
            </p>
          </div>
        </template>
        <template v-else>
          <ul class="gl-list-style-none gl-pl-0">
            <li v-for="group in groups" :key="group.id">{{ group.name }}</li>
            <!-- <groups-list-item
              v-for="namespace in namespaces"
              :key="namespace.id"
              :group="namespace"
            /> -->
          </ul>
        </template>
        <gl-pagination
          v-if="totalItems > perPage && groups.length > 0"
          v-model="page"
          :per-page="perPage"
          :total-items="totalItems"
          @input="loadGroups"
        />
      </gl-tab>
    </gl-tabs>
  </div>
</template>
