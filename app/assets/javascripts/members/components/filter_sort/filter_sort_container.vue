<script>
import { mapState } from 'vuex';
import MembersFilteredSearchBar from './members_filtered_search_bar.vue';
import SortDropdown from './sort_dropdown.vue';

export default {
  name: 'FilterSortContainer',
  components: { MembersFilteredSearchBar, SortDropdown },
  computed: {
    ...mapState(['filteredSearchBarOptions', 'tableSortableFields']),
    showSortDropdown() {
      return this.tableSortableFields.length;
    },
  },
};
</script>

<template>
  <div
    v-if="filteredSearchBarOptions.show || filteredSearchBarOptions.show"
    class="gl-bg-gray-10 gl-p-5"
  >
    <div class="gl-display-md-flex gl-mx-n3 gl-my-n3">
      <div v-if="filteredSearchBarOptions.show" class="gl-p-3 gl-flex-grow-1">
        <members-filtered-search-bar />
      </div>
      <div v-if="filteredSearchBarOptions.show" class="gl-p-3 gl-flex-shrink-0">
        <sort-dropdown />
      </div>
    </div>
  </div>
</template>
