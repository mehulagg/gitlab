<script>
import { GlDropdown, GlSearchBoxByType, GlIcon, GlTruncate, GlDropdownText } from '@gitlab/ui';
import FilterItem from './filter_item.vue';

export default {
  components: {
    GlDropdown,
    GlSearchBoxByType,
    GlIcon,
    GlTruncate,
    GlDropdownText,
    FilterItem,
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
        option.name.toLowerCase().includes(this.filterTerm.toLowerCase()),
      );
    },
    qaSelector() {
      return `filter_${this.filter.name.toLowerCase().replace(' ', '_')}_dropdown`;
    },
  },
  methods: {
    clickFilter(option) {
      this.$emit('setFilter', { filterId: this.filterId, optionId: option.id });
    },
    isSelected(option) {
      return this.selection.has(option.id);
    },
  },
};
</script>

<template>
  <div class="dashboard-filter">
    <strong class="js-name">{{ filter.name }}</strong>
    <gl-dropdown
      class="gl-mt-2 gl-w-full"
      menu-class="dropdown-extended-height"
      :header-text="filter.name"
      toggle-class="gl-w-full"
    >
      <template #button-content>
        <gl-truncate
          :text="firstSelectedOption"
          class="gl-min-w-0 gl-mr-2"
          :data-qa-selector="qaSelector"
        />
        <span v-if="extraOptionCount" class="gl-mr-2">
          {{ n__('+%d more', '+%d more', extraOptionCount) }}
        </span>
        <gl-icon name="chevron-down" class="gl-flex-shrink-0 gl-ml-auto" />
      </template>

      <gl-search-box-by-type
        v-if="filter.options.length >= 20"
        v-model="filterTerm"
        :placeholder="__('Filter...')"
      />

      <filter-item
        v-for="option in filteredOptions"
        :key="option.id"
        :is-checked="isSelected(option)"
        :text="option.name"
        @click="clickFilter(option)"
      />

      <gl-dropdown-text v-if="filteredOptions.length <= 0">
        <span class="gl-text-gray-500">{{ __('No matching results') }}</span>
      </gl-dropdown-text>
    </gl-dropdown>
  </div>
</template>
