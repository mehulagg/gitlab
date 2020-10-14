<script>
import FilterOption from './filter_option.vue';
import FilterBody from './filter_body.vue';

export default {
  components: {
    FilterOption,
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
      filterTerm: '',
      selectedOptions: this.getSelectedOptions(),
    };
  },
  computed: {
    selectedCount() {
      return Object.keys(this.selectedOptions).length;
    },
    firstSelectedOption() {
      if (this.selectedCount > 0) {
        const id = Object.keys(this.selectedOptions)[0];
        const option = this.filter.options.find(x => x.id === id);
        return option?.name || '-';
      }

      return this.filter.allOption.name;
    },
    extraOptionCount() {
      return Math.max(0, this.selectedCount - 1);
    },
    filteredOptions() {
      return this.filter.options.filter(option =>
        option.name.toLowerCase().includes(this.filterTerm.toLowerCase()),
      );
    },
    qaSelector() {
      return `filter_${this.filter.name.toLowerCase().replace(' ', '_')}_dropdown`;
    },
  },
  watch: {
    selectedOptions() {
      const { id } = this.filter;
      const selectedFilters = Object.keys(this.selectedOptions);
      console.log('emit filter-changed', { [id]: selectedFilters });
      this.$router.push({ query: { [id]: selectedFilters } });
      this.$emit('filter-changed', { [id]: selectedFilters });
    },
  },
  methods: {
    getSelectedOptions() {
      const values = this.$route.query[this.filter.id];
      const valueArray = Array.isArray(values) ? values : [values];
      const definedArray = valueArray.filter(x => x !== undefined);
      const selected = {};

      definedArray.forEach(x => {
        selected[x] = true;
      });

      return selected;
    },
    toggleFilter(option) {
      console.log('toggle', option);
      if (this.selectedOptions[option.id]) {
        this.$delete(this.selectedOptions, option.id);
      } else {
        this.$set(this.selectedOptions, option.id, true);
      }
    },
    deselectAllOptions() {
      this.selectedOptions = {};
    },
    isSelected(option) {
      return Boolean(this.selectedOptions[option.id]);
    },
    closeDropdown() {
      this.$refs.dropdown.hide(true);
    },
    updateFilterTerm(newFilterTerm) {
      this.filterTerm = newFilterTerm;
    },
  },
};
</script>

<template>
  <filter-body
    v-model="filterTerm"
    :name="filter.name"
    :selected-options-count="selectedCount"
    :selected-option="firstSelectedOption"
    :show-search-box="filter.options.length > 20"
    @filter-changed="updateFilterTerm"
  >
    <template #specialOptions>
      <filter-option
        v-if="filter.allOption && !filterTerm.length"
        :display-name="filter.allOption.name"
        :is-selected="!selectedCount"
        @click="deselectAllOptions"
      />
    </template>

    <template>
      <filter-option
        v-for="option in filteredOptions"
        :key="option.id"
        type="button"
        class="dropdown-item"
        :display-name="option.name"
        :is-selected="isSelected(option)"
        @click="toggleFilter(option)"
      />
    </template>
  </filter-body>
</template>
