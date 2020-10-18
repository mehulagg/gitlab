<script>
import { GlDropdownItem, GlTruncate } from '@gitlab/ui';

export default {
  components: { GlDropdownItem, GlTruncate },
  props: {
    isChecked: {
      type: Boolean,
      required: false,
      default: false,
    },
    text: {
      type: String,
      required: false,
      default: '',
    },
    showCheckIcon: {
      type: Boolean,
      required: false,
      default: true,
    },
    textClass: {
      type: String,
      required: false,
      default: '',
    },
  },
};
</script>

<template>
  <gl-dropdown-item
    :is-check-item="showCheckIcon"
    :is-checked="showCheckIcon && isChecked"
    @click.native.capture.stop="$emit('click')"
  >
    <slot>
      <gl-truncate :text="text" :class="textClass" />
    </slot>
  </gl-dropdown-item>
</template>
