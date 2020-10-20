<script>
import { GlDropdown, GlSearchBoxByType, GlIcon, GlTruncate, GlDropdownText } from '@gitlab/ui';

export default {
  components: {
    GlDropdown,
    GlSearchBoxByType,
    GlIcon,
    GlTruncate,
    GlDropdownText,
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
    selectedCount: {
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
    extraOptionCount() {
      return Math.max(0, this.selectedCount - 1);
    },
  },
  watch: {
    filterTerm() {
      this.$emit('filter-changed', this.filterTerm);
    },
  },
};
</script>

<template>
  <div class="dashboard-filter">
    <strong class="js-name">{{ name }}</strong>
    <gl-dropdown
      class="gl-mt-2 gl-w-full"
      menu-class="dropdown-extended-height"
      :header-text="name"
      toggle-class="gl-w-full"
    >
      <template #button-content>
        <gl-truncate :text="selectedOption" class="gl-min-w-0 gl-mr-2" />
        <span v-if="extraOptionCount" class="gl-mr-2">
          {{ n__('+%d more', '+%d more', extraOptionCount) }}
        </span>
        <gl-icon name="chevron-down" class="gl-flex-shrink-0 gl-ml-auto" />
      </template>

      <gl-search-box-by-type
        v-if="showSearchBox"
        v-model.trim="filterTerm"
        :placeholder="__('Filter...')"
      />

      <slot>
        <gl-dropdown-text>
          <span class="gl-text-gray-500">{{ __('No matching results') }}</span>
        </gl-dropdown-text>
      </slot>
    </gl-dropdown>
  </div>
</template>
