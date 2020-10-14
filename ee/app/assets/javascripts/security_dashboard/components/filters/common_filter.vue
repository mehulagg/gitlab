<script>
import { GlDropdown, GlSearchBoxByType, GlIcon, GlTruncate } from '@gitlab/ui';

export default {
  components: {
    GlDropdown,
    GlSearchBoxByType,
    GlIcon,
    GlTruncate,
  },
  props: {
    name: {
      type: String,
      required: true,
    },
    selectedOption: {
      type: String,
      required: false,
      default: '',
    },
    selectedOptionsCount: {
      type: Number,
      required: true,
    },
    showSearchBox: {
      type: Boolean,
      required: false,
      default: false,
    },
    value: {
      type: String,
      required: true,
    },
  },
  computed: {
    extraOptionsCount() {
      return Math.max(0, this.selectedOptionsCount - 1);
    },
  },
  methods: {
    qaSelector() {
      return `filter_${this.name.toLowerCase().replace(' ', '_')}_dropdown`;
    },
    closeDropdown() {
      this.$refs.dropdown.hide(true);
    },
  },
};
</script>

<template>
  <div class="dashboard-filter">
    <strong class="js-name">{{ name }}</strong>
    <gl-dropdown
      ref="dropdown"
      class="d-block mt-1"
      menu-class="dropdown-extended-height"
      toggle-class="d-flex w-100 justify-content-between align-items-center"
    >
      <!-- Selected dropdown item -->
      <template slot="button-content">
        <gl-truncate :text="selectedOption" :data-qa-selector="qaSelector" />
        <span v-if="extraOptionsCount > 0" class="flex-grow-1 ml-1">
          {{ n__('+%d more', '+%d more', extraOptionsCount) }}
        </span>
        <i class="fa fa-chevron-down" aria-hidden="true"></i>
      </template>

      <!-- Dropdown title that shows at the top of the dropdown -->
      <div class="dropdown-title mb-0">
        {{ name }}
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
        v-if="showSearchBox"
        ref="searchBox"
        :value="filterTerm"
        class="gl-m-3"
        :placeholder="__('Filter...')"
        @input="$emit('input', $event.target.value)"
      />

      <div data-qa-selector="filter_dropdown_content">
        <slot name="specialOptions"></slot>

        <slot>
          <button type="button" class="dropdown-item no-pointer-events text-secondary">
            {{ __('No matching results') }}
          </button>
        </slot>
      </div>
    </gl-dropdown>
  </div>
</template>
