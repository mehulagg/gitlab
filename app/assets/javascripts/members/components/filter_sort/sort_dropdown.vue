<script>
import { mapState } from 'vuex';
import { GlDropdown, GlDropdownItem, GlFormGroup } from '@gitlab/ui';
import { parseSortParam, buildSortUrl } from '../../utils';
import { FIELDS, DEFAULT_SORT } from '../../constants';

export default {
  name: 'SortDropdown',
  components: { GlDropdown, GlDropdownItem, GlFormGroup },
  data() {
    return {
      ...DEFAULT_SORT,
    };
  },
  computed: {
    ...mapState(['tableSortableFields', 'filteredSearchBar']),
    filteredOptions() {
      return FIELDS.filter(
        field => this.tableSortableFields.includes(field.key) && field.sort,
      ).reduce((accumulator, field) => {
        return [
          ...accumulator,
          {
            ...field.sort.asc,
            key: field.key,
            sortDesc: false,
            url: buildSortUrl({
              sortBy: field.key,
              sortDesc: false,
              filteredSearchBarTokens: this.filteredSearchBar.tokens,
              filteredSearchBarSearchParam: this.filteredSearchBar.searchParam,
            }),
          },
          {
            ...field.sort.desc,
            key: field.key,
            sortDesc: true,
            url: buildSortUrl({
              sortBy: field.key,
              sortDesc: true,
              filteredSearchBarTokens: this.filteredSearchBar.tokens,
              filteredSearchBarSearchParam: this.filteredSearchBar.searchParam,
            }),
          },
        ];
      }, []);
    },
  },
  created() {
    const { sortBy, sortDesc, sortByLabel } = parseSortParam(this.tableSortableFields);

    this.sortBy = sortBy;
    this.sortDesc = sortDesc;
    this.sortByLabel = sortByLabel;
  },
  methods: {
    isChecked(key, sortDesc) {
      return this.sortBy === key && this.sortDesc === sortDesc;
    },
  },
};
</script>

<template>
  <gl-form-group
    :label="__('Sort by')"
    class="gl-mb-0"
    label-cols="auto"
    label-class="gl-align-self-center gl-pb-0!"
  >
    <gl-dropdown
      :text="sortByLabel"
      block
      toggle-class="gl-mb-0"
      data-testid="members-sort-dropdown"
    >
      <gl-dropdown-item
        v-for="option in filteredOptions"
        :key="option.param"
        :href="option.url"
        is-check-item
        :is-checked="isChecked(option.key, option.sortDesc)"
      >
        {{ option.label }}
      </gl-dropdown-item>
    </gl-dropdown>
  </gl-form-group>
</template>
