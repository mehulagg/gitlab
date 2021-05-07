<script>
import { GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlIcon,
  },
  props: {
    icon: {
      type: String,
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    value: {
      type: String,
      required: false,
      default: null,
    },
  },
  computed: {
    tooltipProps() {
      return {
        boundary: 'viewport',
        placement: 'left',
        title: this.value || this.title,
      };
    },
    valueWithFallback() {
      return this.value || this.$options.i18n.none;
    },
    valueClass() {
      return {
        'no-value': !this.value,
      };
    },
  },
  i18n: {
    none: __('None'),
  },
};
</script>

<template>
  <div class="block">
    <div v-gl-tooltip="tooltipProps" class="sidebar-collapsed-icon" data-testid="field-collapsed">
      <gl-icon :name="icon" />
    </div>

    <div class="hide-collapsed">
      <div class="title" data-testid="field-title">{{ title }}</div>
      <div class="value">
        <span :class="valueClass" data-testid="field-value">{{ valueWithFallback }}</span>
      </div>
    </div>
  </div>
</template>
