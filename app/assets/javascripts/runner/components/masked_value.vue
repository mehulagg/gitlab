<script>
import { GlIcon } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  components: {
    GlIcon,
  },
  props: {
    value: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      isMasked: true,
    };
  },
  computed: {
    label() {
      if (this.isMasked) {
        return __('Click to reveal');
      }
      return __('Click to hide');
    },
    icon() {
      if (this.isMasked) {
        return 'eye';
      }
      return 'eye-slash';
    },
    displayedValue() {
      if (this.isMasked && this.value?.length) {
        return '*'.repeat(this.value.length);
      }
      return this.value;
    },
  },
  methods: {
    toggleMasked() {
      this.isMasked = !this.isMasked;
    },
  },
};
</script>
<template>
  <span
    >{{ displayedValue }}
    <gl-icon
      class="gl-hover-cursor-pointer"
      data-testid="toggle-masked"
      :name="icon"
      :aria-label="label"
      @click="toggleMasked"
  /></span>
</template>
