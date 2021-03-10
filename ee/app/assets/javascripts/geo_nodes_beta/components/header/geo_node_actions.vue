<script>
import { GlButton, GlDropdown, GlDropdownItem, GlIcon } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  name: 'GeoNodeActions',
  i18n: {
    editButtonLabel: __('Edit'),
    removeButtonLabel: __('Remove'),
  },
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
      <gl-dropdown-item>{{ $options.i18n.editButtonLabel }}</gl-dropdown-item>
      <gl-dropdown-item :disabled="primary" data-testid="geo-mobile-remove-action">
        <span :class="dropdownRemoveClass">{{ $options.i18n.removeButtonLabel }}</span>
      </gl-dropdown-item>
    </gl-dropdown>
    <div class="gl-display-none gl-lg-display-flex" data-testid="geo-desktop-actions">
      <gl-button class="gl-mr-3">{{ $options.i18n.editButtonLabel }}</gl-button>
      <gl-button
        variant="danger"
        category="secondary"
        :disabled="primary"
        data-testid="geo-desktop-remove-action"
        >{{ $options.i18n.removeButtonLabel }}</gl-button
      >
    </div>
  </div>
</template>
