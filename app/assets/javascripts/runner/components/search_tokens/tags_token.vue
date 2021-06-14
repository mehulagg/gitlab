<script>
import { GlBadge, GlFilteredSearchSuggestion } from '@gitlab/ui';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { s__ } from '~/locale';

import BaseToken from '~/vue_shared/components/filtered_search_bar/tokens/base_token.vue';

export default {
  components: {
    BaseToken,
    GlBadge,
    GlFilteredSearchSuggestion,
  },
  props: {
    config: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      tags: [],
      loading: false,
    };
  },
  methods: {
    getTagsOptions(search) {
      // TODO This should be implemented via a GraphQL API
      // The API should
      // 1) scope to the rights of the user
      // 2) stay up to date to removal of old tags
      return axios.get('/admin/runners/tag_list.json', {
        params: {
          search,
        },
      });
    },
    getActiveTokenValue(tags, currentValue) {
      return tags.find((tag) => tag?.name.toLowerCase() === currentValue);
    },
    async fetchTags(searchTerm) {
      this.loading = true;
      try {
        const res = await this.getTagsOptions(searchTerm);
        this.tags = res.data;
      } catch {
        createFlash({
          message: s__('Runners|Something went wrong while fetching the tags list'),
        });
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>

<template>
  <base-token
    v-bind="$attrs"
    :config="config"
    :tokens-list-loading="loading"
    :token-values="tags"
    :fn-active-token-value="getActiveTokenValue"
    :recent-token-values-storage-key="config.recentTokenValuesStorageKey"
    @fetch-token-values="fetchTags"
    v-on="$listeners"
  >
    <template #view="{ viewTokenProps: { activeTokenValue } }">
      <gl-badge v-if="activeTokenValue" size="sm" variant="info">
        {{ activeTokenValue.name }}
      </gl-badge>
    </template>
    <template #token-values-list="{ tokenValues }">
      <gl-filtered-search-suggestion v-for="tag in tokenValues" :key="tag.name" :value="tag.name">
        {{ tag.name }}
      </gl-filtered-search-suggestion>
    </template>
  </base-token>
</template>
