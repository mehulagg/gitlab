<script>
import { setUrlParams, queryToObject } from '~/lib/utils/url_utility';
import FilteredSearchBar from './filtered_search_bar.vue';
import SortDropdown from './sort_dropdown.vue';
import FilteredSearchBar from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';

export default {
  name: 'FilterSortContainer',
  components: { FilteredSearchBar, SortDropdown },
  props: {
    namespace: {
      type: Number,
      required: true,
    },
    tokens: {
      type: Array,
      required: true,
    },
    sortableFields: {
      type: Array,
      required: false,
    },
    filterBarVisible: {
      type: Boolean,
      required: false,
      default: false,
    },
    searchPlaceholder: {
      type: String,
      required: false,
    },
  },
  data() {
    return {
      initialFilterValue: [],
    };
  },
  computed: {
    searchQuery() {
      return queryToObject(window.location.search);
    },
    isSortVisible() {
      return this.sortableFields.length;
    },
  },
  created() {
    this.applyTokensFromSearch();
  },
  methods: {
    applyTokensFromSearch() {},
    filterChanged() {
      window.location.href = setUrlParams({}, window.location.href, true);
    },
  },
};
</script>

<template>
  <div class="gl-bg-gray-10 gl-p-3 gl-md-display-flex">
    <filtered-search-bar
      v-if="filteredBarVisible"
      :namespace="namespace"
      :tokens="tokens"
      :search-input-placeholder="searchPlaceholder"
      :initial-filter-value="initialFilterValue"
      @onFilter="filterChanged"
      class="gl-p-3 gl-flex-grow-1"
    />
    <sort-dropdown v-if="isSortVisible" class="gl-p-3 gl-flex-shrink-0" />
  </div>
</template>
