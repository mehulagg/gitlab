<script>
import { GlLoadingIcon } from '@gitlab/ui';

export default {
  components: { GlLoadingIcon },
  props: {
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    hasHeaderSlot() {
      return Boolean(this.$slots.header);
    },
    hasStickySlot() {
      return Boolean(this.$slots.sticky);
    },
  },
};
</script>

<template>
  <section class="gl-mt-4">
    <gl-loading-icon v-if="isLoading" size="lg" class="gl-mt-6" />

    <template v-else>
      <header v-if="hasHeaderSlot">
        <slot name="header"></slot>
      </header>

      <section
        v-if="hasStickySlot"
        data-testid="sticky-section"
        class="position-sticky gl-z-index-3 security-dashboard-filters"
      >
        <slot name="sticky"></slot>
      </section>

      <slot></slot>
    </template>
  </section>
</template>
