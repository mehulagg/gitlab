<script>
import { GlDropdownItem, GlTruncate } from '@gitlab/ui';
import FilterBody from './filter_body.vue';

export default {
  components: {
    GlDropdownItem,
    GlTruncate,
    FilterBody,
  },
  props: {
    filter: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      searchTerm: '',
    };
  },
  computed: {
    filterId() {
      return this.filter.id;
    },
    selection() {
      return this.filter.selection;
    },
    firstSelectedOption() {
      return this.filter.options.find(option => this.selection.has(option.id))?.name || '-';
    },
    extraOptionCount() {
      return this.selection.size - 1;
    },
    filteredOptions() {
      return this.filter.options.filter(option =>
        option.name.toLowerCase().includes(this.searchTerm.toLowerCase()),
      );
    },
  },
  methods: {
    clickFilter(option) {
      this.$emit('setFilter', { filterId: this.filterId, optionId: option.id });
      // b-dropdown-item, which is used by GlDropdownItem, is hard-coded to always close the dropdown:
      // https://github.com/bootstrap-vue/bootstrap-vue/blob/dev/src/components/dropdown/dropdown-item.js#L49-L52
      // We'll work around this be re-opening the dropdown when the GlDropdownItem is clicked.
      this.$refs.filterBody.showDropdown();
    },
    isSelected(option) {
      return this.selection.has(option.id);
    },
  },
};
</script>

<template>
  <filter-body
    ref="filterBody"
    v-model.trim="searchTerm"
    :name="filter.name"
    :selected-count="selection.size"
    :selected-option="firstSelectedOption"
    :show-search-box="filter.options.length >= 20"
  >
    <gl-dropdown-item
      v-for="option in filteredOptions"
      :key="option.id"
      is-check-item
      :is-checked="isSelected(option)"
      @click="clickFilter(option)"
    >
      <gl-truncate :text="option.name" />
    </gl-dropdown-item>
  </filter-body>
</template>
