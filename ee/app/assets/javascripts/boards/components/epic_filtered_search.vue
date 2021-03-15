<script>
import { mapActions } from 'vuex';
import { historyPushState } from '~/lib/utils/common_utils';
import { setUrlParams } from '~/lib/utils/url_utility';
import { __ } from '~/locale';
import FilteredSearch from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';

export default {
  i18n: {
    search: __('Search'),
  },
  inject: ['search'],
  components: { FilteredSearch },
  computed: {
    initialSearch() {
      return [{ type: 'filtered-search-term', value: { data: this.search } }];
    },
  },
  methods: {
    ...mapActions(['performSearch']),
    handleSearch(filters = []) {
      const [item] = filters;
      const itemValue = item?.value?.data || '';

      historyPushState(setUrlParams({ search: itemValue }));

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
    :search-input-placeholder="$options.i18n.search"
    :initial-filter-value="initialSearch"
    @onFilter="handleSearch"
  />
</template>
