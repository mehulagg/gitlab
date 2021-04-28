<script>
import { GlButton, GlDrawer, GlIcon } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  i18n: {
    toggleTxt: __('Collapse'),
  },
  navBarHeight: 48,
  sharedBtnClasses: 'gl-w-full gl-rounded-0! gl-inset-border-b-1-gray-200!',
  components: {
    GlButton,
    GlDrawer,
    GlIcon,
  },
  props: {
    isExpanded: {
      type: Boolean,
      required: true,
    },
  },
  methods: {
    toggleDrawer() {
      this.$emit('toggleDrawer');
    },
  },
};
</script>
<template>
  <aside
    aria-live="polite"
    class="pipeline-drawer gl-fixed gl-right-0 gl-h-full gl-bg-gray-10 gl-transition-medium"
  >
    <gl-drawer :open="isExpanded" class="pipeline-drawer" @close="toggleDrawer">
      <slot name="header"></slot>
      <slot></slot>
    </gl-drawer>
    <gl-button
      v-if="!isExpanded"
      icon="chevron-double-lg-left"
      category="tertiary"
      :class="$options.sharedBtnClasses"
      :style="{ height: '48px', width: '58px' }"
      @click="toggleDrawer"
    />
  </aside>
</template>
