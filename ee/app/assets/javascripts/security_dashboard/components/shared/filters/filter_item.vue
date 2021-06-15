<script>
import { GlDropdownItem, GlTruncate } from '@gitlab/ui';

export default {
  components: { GlDropdownItem, GlTruncate },
  props: {
    isChecked: {
      type: Boolean,
      required: true,
    },
    text: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    qaSelector() {
      return `filter_${this.text.toLowerCase().replace(' ', '_')}_dropdown`;
    },
  },
};
</script>

<template>
  <gl-dropdown-item
    is-check-item
    :is-checked="isChecked"
    :data-qa-selector="qaSelector"
    @click.native.capture.stop="$emit('click')"
  >
    <slot>
      <gl-truncate :text="text" />
    </slot>
  </gl-dropdown-item>
</template>
