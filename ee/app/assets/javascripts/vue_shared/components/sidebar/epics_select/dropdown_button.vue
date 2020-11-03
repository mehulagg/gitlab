<script>
import { GlIcon, GlDropdown } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  components: {
    GlIcon,
    GlDropdown,
  },
  props: {
    selectedEpicTitle: {
      type: String,
      required: false,
      default: '',
    },
    toggleTextClass: {
      type: Object,
      required: false,
      default: null,
    },
  },
  computed: {
    buttonText() {
      return this.selectedEpicTitle || __('Epic');
    },
  },
};
</script>

<template>
  <button
    type="button"
    class="dropdown-menu-toggle js-epic-select js-extra-options gl-w-full"
    data-display="static"
    data-toggle="gl-dropdown"
  >
    <span class="dropdown-toggle-text" :class="toggleTextClass">{{ buttonText }}</span>
    <gl-icon name="chevron-down" class="dropdown-menu-toggle-icon gl-top-3" />
  </button>
</template>
