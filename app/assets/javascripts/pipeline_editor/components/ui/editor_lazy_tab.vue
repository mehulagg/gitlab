<script>
import { GlTab } from '@gitlab/ui';

/**
 * Wrapper of <gl-tab> to lazily render this tab's content
 * when shown **without dismounting it after**.
 *
 * Once the tab is selected it is permanently set as "not-lazy"
 * so it's contents are not dismounted.
 *
 * Usage:
 *
 * Same as <gl-tab>, for example:
 *
 * <gl-tabs>
 *   <editor-lazy-tab title="Tab 1"> ... </editor-lazy-tab>
 *   <editor-lazy-tab title="Tab 2"> ... </editor-lazy-tab>
 * </gl-tabs>
 */
export default {
  components: {
    GlTab,
  },
  props: {
    lazy: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  data() {
    return {
      isLazy: this.lazy,
    };
  },
  methods: {
    onClick() {
      this.isLazy = false;
    },
  },
};
</script>
<template>
  <gl-tab :lazy="isLazy" v-bind="$attrs" v-on="$listeners" @click="onClick">
    <slot v-for="slot in Object.keys($slots)" :slot="slot" :name="slot"></slot>
  </gl-tab>
</template>
