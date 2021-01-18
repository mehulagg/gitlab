<script>
import { __ } from '~/locale';

export default {
  props: {
    defaultExpanded: {
      type: Boolean,
      default: false,
      required: false,
    },
  },
  data() {
    return {
      sectionExpanded: false,
    };
  },
  computed: {
    expanded() {
      return this.defaultExpanded || this.sectionExpanded;
    },
    toggleText() {
      return this.expanded ? __('Collapse') : __('Expand');
    },
  },
};
</script>

<template>
  <section class="settings no-animate" :class="{ expanded }">
    <div class="settings-header">
      <h4><slot name="title"></slot></h4>
      <button data-testid="expand-button" class="btn" @click="sectionExpanded = !sectionExpanded">
        {{ toggleText }}
      </button>
      <p>
        <slot name="description"></slot>
      </p>
    </div>
    <div class="settings-content">
      <slot></slot>
    </div>
  </section>
</template>
