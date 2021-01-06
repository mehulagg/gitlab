<script>
import { parseIntPagination, normalizeHeaders } from '~/lib/utils/common_utils';
import { fetchGroups } from '~/jira_connect/api';

export default {
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
      perPage: 10,
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
    <p v-for="group in groups" :key="group.id">{{ group.name }}</p>
  </div>
</template>
