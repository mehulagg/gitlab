<script>
import { GlDropdown, GlDropdownItem, GlIcon } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  name: 'GeoNodeActionsMobile',
  i18n: {
    editButtonLabel: __('Edit'),
    removeButtonLabel: __('Remove'),
  },
  components: {
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
  <gl-dropdown toggle-class="gl-shadow-none! gl-bg-transparent! gl-p-3!" right>
    <template #button-content>
      <gl-icon name="ellipsis_h" />
    </template>
    <gl-dropdown-item>{{ $options.i18n.editButtonLabel }}</gl-dropdown-item>
    <gl-dropdown-item :disabled="primary" data-testid="geo-mobile-remove-action">
      <span :class="dropdownRemoveClass">{{ $options.i18n.removeButtonLabel }}</span>
    </gl-dropdown-item>
  </gl-dropdown>
</template>
