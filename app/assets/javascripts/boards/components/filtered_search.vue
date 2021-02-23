<script>
import { mapActions } from 'vuex';
import { historyPushState } from '~/lib/utils/common_utils';
import { setUrlParams } from '~/lib/utils/url_utility';
import FilteredSearch from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';

export default {
  components: { FilteredSearch },
  props: {
    search: {
      type: String,
      required: false,
      default: '',
    },
  },
  mounted() {
    const searchWrapper = document.querySelector('.filtered-search-wrapper');

    searchWrapper.classList.add('gl-display-none!');
  },
  methods: {
    ...mapActions(['performSearch']),
    handleSearch(filters) {
      let itemValue = '';
      const [item] = filters;

      if (filters.length === 0) {
        itemValue = '';
      } else {
        itemValue = item?.value?.data;
      }

      historyPushState(setUrlParams({ search: itemValue }, window.location.href));

      this.performSearch();
    },
  },
};
</script>

<template>
  <filtered-search
    class="gl-w-full"
    namespace=""
    :tokens="[]"
    :search-input-placeholder="'Search'"
    :initial-filter-value="[{ type: 'filtered-search-term', value: { data: search } }]"
    @onFilter="handleSearch"
  />
</template>
