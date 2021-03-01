<script>
import { GlButton, GlDropdown, GlDropdownItem, GlIcon } from '@gitlab/ui';

export default {
  name: 'GeoNodeActions',
  components: {
    GlButton,
    GlDropdown,
    GlDropdownItem,
    GlIcon,
  },
  props: {
    primary: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      showActions: false,
    };
  },
  computed: {
    dropdownRemoveClass() {
      return this.primary ? 'gl-text-gray-400' : 'gl-text-red-500';
    },
  },
};
</script>

<template>
  <div>
    <gl-dropdown
      class="gl-lg-display-none"
      toggle-class="gl-shadow-none! gl-bg-transparent! gl-p-3!"
      right
    >
      <template #button-content>
        <gl-icon name="ellipsis_h" />
      </template>
      <gl-dropdown-item>{{ __('Edit') }}</gl-dropdown-item>
      <gl-dropdown-item :disabled="primary"
        ><span :class="dropdownRemoveClass">{{ __('Remove') }}</span></gl-dropdown-item
      >
    </gl-dropdown>
    <div class="gl-display-none gl-lg-display-flex">
      <gl-button class="gl-mr-3">{{ __('Edit') }}</gl-button>
      <gl-button variant="danger" category="secondary" :disabled="primary">{{
        __('Remove')
      }}</gl-button>
    </div>
  </div>
</template>
