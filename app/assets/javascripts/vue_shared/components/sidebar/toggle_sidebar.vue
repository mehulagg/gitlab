<script>
import { GlTooltipDirective } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  name: 'ToggleSidebar',
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    collapsed: {
      type: Boolean,
      required: true,
    },
    cssClasses: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    tooltipLabel() {
      return this.collapsed ? __('Expand sidebar') : __('Collapse sidebar');
    },
  },
  methods: {
    toggle() {
      this.$emit('toggle');
    },
  },
};
</script>

<template>
  <button
    v-gl-tooltip:body.viewport.left
    :title="tooltipLabel"
    :class="cssClasses"
    type="button"
    class="btn btn-blank gutter-toggle btn-sidebar-action js-sidebar-vue-toggle"
    @click="toggle"
  >
    <i
      :class="{
        'fa-angle-double-right': !collapsed,
        'fa-angle-double-left': collapsed,
      }"
      :aria-label="__('toggle collapse')"
      class="fa"
    >
    </i>
  </button>
</template>
