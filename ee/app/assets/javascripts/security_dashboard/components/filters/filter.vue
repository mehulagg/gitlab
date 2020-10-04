<script>
import { GlDropdown, GlSearchBoxByType, GlIcon } from '@gitlab/ui';
import { ALL } from 'ee/security_dashboard/store/modules/filters/constants';
import FilterOption from './filter_option.vue';

export default {
  components: {
    GlDropdown,
    GlSearchBoxByType,
    GlIcon,
    FilterOption,
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
      selectedOptions: {},
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
        return option.name;
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
      this.$emit('filter-changed', { [id]: selectedFilters });
    },
    '$route.query': {
      immediate: true,
      handler(query) {
        const values = query[this.filter.id];
        const valueArray = Array.isArray(values) ? values : [values];
        const definedArray = valueArray.filter(x => x !== undefined);
        definedArray.forEach(value => {
          this.$set(this.selectedOptions, value, true);
        });
      },
    },
  },
  methods: {
    toggleFilter(option) {
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
      // Special case for the All option, return true if there are no other selected options.
      if (option.id === ALL && this.selectedCount <= 0) {
        return true;
      }

      return Boolean(this.selectedOptions[option.id]);
    },
    closeDropdown() {
      this.$refs.dropdown.hide(true);
    },
  },
};
</script>

<template>
  <div class="dashboard-filter">
    <strong class="js-name">{{ filter.name }}</strong>
    <gl-dropdown
      ref="dropdown"
      class="d-block mt-1"
      menu-class="dropdown-extended-height"
      toggle-class="d-flex w-100 justify-content-between align-items-center"
    >
      <!-- Selected dropdown item -->
      <template slot="button-content">
        <span class="text-truncate" :data-qa-selector="qaSelector">
          {{ firstSelectedOption }}
        </span>
        <span v-if="extraOptionCount" class="flex-grow-1 ml-1">
          {{ n__('+%d more', '+%d more', extraOptionCount) }}
        </span>
        <i class="fa fa-chevron-down" aria-hidden="true"></i>
      </template>

      <!-- Dropdown title that shows in the dropdown -->
      <div class="dropdown-title mb-0">
        {{ filter.name }}
        <button
          ref="close"
          class="btn-blank float-right"
          type="button"
          :aria-label="__('Close')"
          @click="closeDropdown"
        >
          <gl-icon name="close" aria-hidden="true" class="vertical-align-middle" />
        </button>
      </div>

      <gl-search-box-by-type
        v-if="filter.options.length >= 4"
        ref="searchBox"
        v-model="filterTerm"
        class="gl-m-3"
        :placeholder="__('Filter...')"
      />

      <div
        data-qa-selector="filter_dropdown_content"
        :class="{ 'dropdown-content': filter.id === 'project_id' }"
      >
        <filter-option
          v-if="filter.allOption && !filterTerm.length"
          :display-name="filter.allOption.name"
          :is-selected="!selectedCount"
          @click="deselectAllOptions"
        />

        <slot :is-selected="isSelected" :clickFilter="toggleFilter">
          <filter-option
            v-for="option in filteredOptions"
            :key="option.id"
            type="button"
            class="dropdown-item"
            :display-name="option.name"
            :is-selected="isSelected(option)"
            @click="toggleFilter(option)"
          />
        </slot>
      </div>

      <button
        v-if="filteredOptions.length === 0"
        type="button"
        class="dropdown-item no-pointer-events text-secondary"
      >
        {{ __('No matching results') }}
      </button>
    </gl-dropdown>
  </div>
</template>
