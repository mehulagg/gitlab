<script>
import { GlLoadingIcon } from '@gitlab/ui';
import ListContent from './list_content.vue';
import ListFilter from './list_filter.vue';

export default {
  components: {
    ListFilter,
    ListContent,
    GlLoadingIcon,
  },
  props: {
    loading: {
      type: Boolean,
      required: true,
    },
    items: {
      type: Array,
      required: true,
    },
    listType: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      query: '',
    };
  },
  computed: {
    filteredItems() {
      if (!this.query) return this.items;

      const query = this.query.toLowerCase();
      return this.items.filter((item) => {
        const name = item.name ? item.name.toLowerCase() : item.title.toLowerCase();

        if (this.listType === 'milestones') {
          return name.indexOf(query) > -1;
        }

        const username = item.username.toLowerCase();
        return name.indexOf(query) > -1 || username.indexOf(query) > -1;
      });
    },
  },
  methods: {
    handleSearch(query) {
      this.query = query;
    },
    handleItemClick(item) {
      this.$emit('onItemSelect', item);
    },
  },
};
</script>

<template>
  <div class="dropdown-assignees-list">
    <div v-if="loading" class="dropdown-loading"><gl-loading-icon size="sm" /></div>
    <list-filter @onSearchInput="handleSearch" />
    <list-content
      v-if="!loading"
      :items="filteredItems"
      :list-type="listType"
      @onItemSelect="handleItemClick"
    />
  </div>
</template>
