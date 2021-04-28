<script>
import { GlButton, GlIcon } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  i18n: {
    toggleTxt: __('Collapse'),
  },
  navBarHeight: 48,
  sharedBtnClasses: 'gl-w-full gl-rounded-0! gl-inset-border-b-1-gray-200!',
  components: {
    GlButton,
    GlIcon,
  },
  props: {
    isExpanded: {
      type: Boolean,
      required: true,
    },
    expandedWidth: {
      type: Number,
      required: true,
    },
  },
  computed: {
    heightStyle() {
      return { height: `${this.$options.navBarHeight}px` };
    },
    rootStyle() {
      return this.isExpanded ? { width: `${this.expandedWidth}px` } : { width: '58px' };
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
    :style="rootStyle"
  >
    <gl-button
      v-if="isExpanded"
      category="tertiary"
      class="gl-text-decoration-none! gl-outline-0! gl-display-flex gl-justify-content-end!"
      :class="$options.sharedBtnClasses"
      :style="heightStyle"
      :title="__('Toggle sidebar')"
      data-testid="icon-expand"
      @click="toggleDrawer"
    >
      <span class="gl-text-gray-400 gl-mr-3">{{ __('Collapse') }}</span>
      <gl-icon data-testid="icon-collapse" name="chevron-double-lg-right" />
    </gl-button>
    <gl-button
      v-else
      icon="chevron-double-lg-left"
      category="tertiary"
      :class="$options.sharedBtnClasses"
      :style="heightStyle"
      @click="toggleDrawer"
    />
    <div data-testid="sidebar-items" class="issuable-sidebar">
      <slot name="right-sidebar-items" v-bind="{ sidebarExpanded: isExpanded }"></slot>
    </div>
  </aside>
</template>
