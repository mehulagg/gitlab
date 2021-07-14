<script>
import { GlButton, GlTooltipDirective } from '@gitlab/ui';

export default {
  name: 'ClipboardButton',
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlButton,
  },
  props: {
    text: {
      type: String,
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    gfm: {
      type: String,
      required: false,
      default: null,
    },
    tooltipPlacement: {
      type: String,
      required: false,
      default: 'top',
    },
    tooltipContainer: {
      type: [String, Boolean],
      required: false,
      default: false,
    },
    tooltipBoundary: {
      type: String,
      required: false,
      default: null,
    },
    cssClass: {
      type: String,
      required: false,
      default: null,
    },
    category: {
      type: String,
      required: false,
      default: 'secondary',
    },
    size: {
      type: String,
      required: false,
      default: 'medium',
    },
  },
  computed: {
    clipboardText() {
      if (this.gfm !== null) {
        return JSON.stringify({ text: this.text, gfm: this.gfm });
      }
      return this.text;
    },
  },
  methods: {
    async onClick() {
      await navigator.clipboard.writeText(this.clipboardText);
    },
  },
};
</script>

<template>
  <gl-button
    v-gl-tooltip.hover.blur.viewport="{
      placement: tooltipPlacement,
      container: tooltipContainer,
      boundary: tooltipBoundary,
    }"
    :class="cssClass"
    :title="title"
    :category="category"
    :size="size"
    icon="copy-to-clipboard"
    :aria-label="__('Copy this value')"
    v-on="$listeners"
    @click.prevent.stop="onClick"
  >
    <slot></slot>
  </gl-button>
</template>
