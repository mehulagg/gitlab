<script>
import { GlDeprecatedDropdown, GlSearchBoxByType, GlIcon } from '@gitlab/ui';

export default {
  components: {
    GlDeprecatedDropdown,
    GlSearchBoxByType,
    GlIcon,
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
    closeDropdown() {
      this.$refs.dropdown.$children[0].hide(true);
    },
  },
};
</script>

<template>
  <div class="dashboard-filter">
    <strong class="js-name">{{ filter.name }}</strong>
    <gl-deprecated-dropdown
      ref="dropdown"
      class="d-block mt-1"
      menu-class="dropdown-extended-height"
      toggle-class="d-flex w-100 justify-content-between align-items-center"
    >
      <template slot="button-content">
        <span class="text-truncate" :data-qa-selector="qaSelector">
          {{ firstSelectedOption }}
        </span>
        <span v-if="extraOptionCount" class="flex-grow-1 ml-1">
          {{ n__('+%d more', '+%d more', extraOptionCount) }}
        </span>
        <i class="fa fa-chevron-down" aria-hidden="true"></i>
      </template>

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
        v-if="filter.options.length >= 20"
        ref="searchBox"
        v-model="filterTerm"
        class="gl-m-3"
        :placeholder="__('Filter...')"
      />

      <div
        data-qa-selector="filter_dropdown_content"
        :class="{ 'dropdown-content': filterId === 'project_id' }"
      >
        <button
          v-for="option in filteredOptions"
          :key="option.id"
          role="menuitem"
          type="button"
          class="dropdown-item"
          @click="clickFilter(option)"
        >
          <span class="d-flex">
            <gl-icon
              v-if="isSelected(option)"
              class="flex-shrink-0 js-check"
              name="mobile-issue-close"
            />
            <span class="gl-white-space-nowrap gl-ml-2" :class="{ 'gl-pl-5': !isSelected(option) }">
              {{ option.name }}
            </span>
          </span>
        </button>
      </div>

      <button
        v-if="filteredOptions.length === 0"
        type="button"
        class="dropdown-item no-pointer-events text-secondary"
      >
        {{ __('No matching results') }}
      </button>
    </gl-deprecated-dropdown>
  </div>
</template>
