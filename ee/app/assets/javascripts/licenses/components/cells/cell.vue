<script>
import { isNumber } from 'lodash';

export default {
  // name: 'Cell' is a false positive: https://gitlab.com/gitlab-org/frontend/eslint-plugin-i18n/issues/25
  // eslint-disable-next-line @gitlab/require-i18n-strings
  name: 'Cell',
  props: {
    title: {
      type: String,
      required: false,
      default: null,
    },
    value: {
      type: [String, Number],
      required: false,
      default: null,
    },
    isFlexible: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  computed: {
    valueClass() {
      return { number: isNumber(this.value) };
    },
    flexClass() {
      return { 'flex-grow-1': this.isFlexible };
    },
  },

  emits: [],
};
</script>

<template>
  <div class="license-cell p-3 text-nowrap flex-shrink-0" :class="flexClass">
    <span class="title d-flex align-items-center justify-content-start">
      <slot name="title">
        <span>{{ title }}</span>
      </slot>
    </span>

    <div class="value mt-2" :class="valueClass">
      <slot name="value">
        <span>{{ value }}</span>
      </slot>
    </div>
  </div>
</template>
