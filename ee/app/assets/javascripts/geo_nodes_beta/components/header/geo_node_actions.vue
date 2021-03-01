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
      <gl-dropdown-item :disabled="primary" data-testid="geoMobileRemoveAction">
        <span :class="dropdownRemoveClass">{{ __('Remove') }}</span>
      </gl-dropdown-item>
    </gl-dropdown>
    <div class="gl-display-none gl-lg-display-flex" data-testid="geoDesktopActions">
      <gl-button class="gl-mr-3">{{ __('Edit') }}</gl-button>
      <gl-button
        variant="danger"
        category="secondary"
        :disabled="primary"
        data-testid="geoDesktopRemoveAction"
        >{{ __('Remove') }}</gl-button
      >
    </div>
  </div>
</template>
