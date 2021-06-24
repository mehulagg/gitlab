<script>
import { GlDrawer } from '@gitlab/ui';

export default {
  components: {
    GlDrawer,
  },
  props: {
    mergeRequest: {
      type: Object,
      required: true,
    },
    showDrawer: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  methods: {
    getDrawerHeaderHeight() {
      const wrapperEl = document.querySelector('.content-wrapper');

      if (wrapperEl) {
        return `${wrapperEl.offsetTop}px`;
      }

      return '';
    },
  },
  // We set the drawer's z-index to 252 to clear flash messages that might be displayed in the page
  // and that have a z-index of 251.
  Z_INDEX: 252,
};
</script>
<template>
  <gl-drawer
    :open="showDrawer"
    :header-height="getDrawerHeaderHeight()"
    :z-index="$options.Z_INDEX"
    @close="$emit('close')"
  >
    <template #header>
      <h4 data-testid="dashboard-drawer-title">{{ mergeRequest.title }}</h4>
    </template>
  </gl-drawer>
</template>
