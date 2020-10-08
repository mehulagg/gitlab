<script>
import $ from 'jquery';
import { GlIcon } from '@gitlab/ui';
import { GlBreakpointInstance as bp } from '@gitlab/ui/dist/utils';

export default {
  initialBreakpoint: bp.getBreakpointSize(),
  collapseOnBreakpoints: ['md', 'sm', 'xs'],
  components: {
    GlIcon,
  },
  props: {
    expanded: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  data() {
    return {
      isExpanded: this.expanded,
    };
  },
  watch: {
    expanded(value) {
      this.isExpanded = value;
    },
  },
  mounted() {
    $(window).on('resize.app', this.handleWindowResize.bind(this));
  },
  methods: {
    handleWindowResize() {
      if (this.expanded) {
        const breakpoint = bp.getBreakpointSize();
        if (breakpoint !== this.$options.initialBreakpoint) {
          if (this.$options.collapseOnBreakpoints.includes(breakpoint)) {
            this.isExpanded = false;
          } else {
            this.isExpanded = true;
          }
        }
        this.$emit('sidebar-toggle', {
          expanded: this.isExpanded,
          manual: false,
        });
      }
    },
    handleToggleSidebarClick() {
      this.isExpanded = !this.isExpanded;
      this.$emit('sidebar-toggle', {
        expanded: this.isExpanded,
        manual: true,
      });
    },
  },
};
</script>

<template>
  <aside
    :class="{ 'right-sidebar-expanded': isExpanded, 'right-sidebar-collapsed': !isExpanded }"
    class="right-sidebar"
    aria-live="polite"
  >
    <button
      class="toggle-right-sidebar-button js-toggle-right-sidebar-button w-100 gl-text-decoration-none! gl-display-flex gl-outline-0!"
      :title="__('Toggle sidebar')"
      @click="handleToggleSidebarClick"
    >
      <span v-if="isExpanded" class="collapse-tex gl-flex-grow-1 gl-text-left">{{
        __('Collapse sidebar')
      }}</span>
      <gl-icon v-show="isExpanded" data-testid="icon-collapse" name="chevron-double-lg-right" />
      <gl-icon
        v-show="!isExpanded"
        data-testid="icon-expand"
        name="chevron-double-lg-left"
        class="gl-ml-2"
      />
    </button>
    <div data-testid="sidebar-items" class="issuable-sidebar">
      <slot name="right-sidebar-items" v-bind="{ sidebarExpanded: isExpanded }"></slot>
    </div>
  </aside>
</template>
