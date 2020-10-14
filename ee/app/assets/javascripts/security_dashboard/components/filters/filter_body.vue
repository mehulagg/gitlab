<script>
import {
  GlDropdown,
  GlDropdownForm,
  GlDropdownItem,
  GlSearchBoxByType,
  GlIcon,
  GlTruncate,
} from '@gitlab/ui';

export default {
  components: {
    GlDropdown,
    GlDropdownForm,
    GlDropdownItem,
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
  },
  data: () => ({
    filterTerm: '',
  }),
  computed: {
    extraOptionsCount() {
      return Math.max(0, this.selectedOptionsCount - 1);
    },
    qaSelector() {
      return `filter_${this.name.toLowerCase().replace(' ', '_')}_dropdown`;
    },
  },
  watch: {
    filterTerm(filterTerm) {
      this.$emit('filter-changed', filterTerm);
    },
  },
  methods: {
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
      class="gl-mt-2 gl-w-full dropdown-extended-height"
      :header-text="name"
      toggle-class="gl-w-full gl-display-block"
    >
      <template #button-content>
        <gl-truncate :text="selectedOption" class="gl-min-w-0 gl-flex-fill-1" />
        <span v-if="extraOptionsCount" class="gl-ml-2">
          {{ n__('+%d more', '+%d more', extraOptionsCount) }}
        </span>
        <gl-icon name="chevron-down" class="gl-flex-shrink-0" />
      </template>

      <gl-search-box-by-type
        v-if="showSearchBox"
        ref="searchBox"
        v-model.trim="filterTerm"
        class="gl-m-3"
        :placeholder="__('Filter...')"
      />

      <slot name="specialOptions"></slot>

      <slot>
        <gl-dropdown-item disabled>
          <span class="gl-text-gray-400">{{ __('No matching results') }}</span>
        </gl-dropdown-item>
      </slot>
    </gl-dropdown>
  </div>
</template>
