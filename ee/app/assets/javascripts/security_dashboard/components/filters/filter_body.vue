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
    value: {
      type: String,
      required: false,
      default: '',
    },
    name: {
      type: String,
      required: true,
    },
    selectedOptions: {
      type: Array,
      required: true,
    },
    showSearchBox: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    firstSelectedOption() {
      return this.selectedOptions[0] || '-';
    },
    extraOptionCount() {
      return this.selectedOptions.length - 1;
    },
    qaSelector() {
      return `filter_${this.name.toLowerCase().replace(' ', '_')}_dropdown`;
    },
  },
  methods: {
    emitInput(value) {
      this.$emit('input', value);
    },
  },
};
</script>

<template>
  <div class="dashboard-filter">
    <strong data-testid="name">{{ name }}</strong>
    <gl-dropdown
      class="gl-mt-2 gl-w-full"
      menu-class="dropdown-extended-height"
      :header-text="name"
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
        v-if="showSearchBox"
        :placeholder="__('Filter...')"
        @input="emitInput"
      />

      <slot>
        <gl-dropdown-text>
          <span class="gl-text-gray-500">{{ __('No matching results') }}</span>
        </gl-dropdown-text>
      </slot>
    </gl-dropdown>
  </div>
</template>
