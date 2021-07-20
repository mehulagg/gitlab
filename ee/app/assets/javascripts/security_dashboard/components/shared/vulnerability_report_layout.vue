<script>
export default {
  computed: {
    hasHeaderSlot() {
      return Boolean(this.$slots.header);
    },
    hasStickySlot() {
      return Boolean(this.$slots.sticky);
    },
    hasAsideSlot() {
      return Boolean(this.$slots.aside);
    },
  },
};
</script>

<template>
  <section>
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

    <div class="row mt-4">
      <article class="col" :class="{ 'col-xl-7': hasAsideSlot }">
        <slot></slot>
      </article>

      <aside v-if="hasAsideSlot" class="col-xl-5">
        <slot name="aside"></slot>
      </aside>
    </div>
  </section>
</template>
