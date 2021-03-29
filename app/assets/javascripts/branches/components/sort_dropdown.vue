<script>
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { mergeUrlParams, visitUrl, getParameterValues } from '~/lib/utils/url_utility';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
  },
  inject: [
    'projectBranchesFilteredPath',
    'sortOptionNameAsc',
    'sortOptionUpdatedAsc',
    'sortOptionUpdatedDesc',
  ],
  data() {
    return {
      selectedItem: this.sortOptionUpdatedDesc,
    };
  },
  created() {
    const sortValue = getParameterValues('sort');

    if (sortValue.length) {
      [this.selectedItem] = sortValue;
    }
  },
  methods: {
    isSortMethodSelected(sortOption) {
      return sortOption === this.selectedItem;
    },
    visitUrlFromOption(sortOption) {
      this.selectedItem = sortOption;

      const newUrl = mergeUrlParams({ sort: sortOption }, this.projectBranchesFilteredPath);
      visitUrl(newUrl);
    },
  },
};
</script>
<template>
  <gl-dropdown :text="selectedItem">
    <gl-dropdown-item
      :is-checked="isSortMethodSelected(sortOptionNameAsc)"
      @click="visitUrlFromOption(sortOptionNameAsc)"
      >{{ sortOptionNameAsc }}</gl-dropdown-item
    >
    <gl-dropdown-item :is-checked="isSortMethodSelected(sortOptionUpdatedAsc)">{{
      sortOptionUpdatedAsc
    }}</gl-dropdown-item>
    <gl-dropdown-item :is-checked="isSortMethodSelected(sortOptionUpdatedDesc)">{{
      sortOptionUpdatedDesc
    }}</gl-dropdown-item>
  </gl-dropdown>
</template>
