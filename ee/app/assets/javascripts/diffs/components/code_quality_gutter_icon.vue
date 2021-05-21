<script>
import { GlTooltipDirective, GlIcon } from '@gitlab/ui';
import { SEVERITY_CLASSES, SEVERITY_ICONS } from '~/reports/codequality_report/constants';

export default {
  components: {
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    codequality: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  computed: {
    description() {
      return this.codequality[0].description;
    },
    severity() {
      return this.codequality[0].severity;
    },
    severityClass() {
      return SEVERITY_CLASSES[this.severity] || SEVERITY_CLASSES.unknown;
    },
    severityIcon() {
      return SEVERITY_ICONS[this.severity] || SEVERITY_ICONS.unknown;
    },
  },
};
</script>

<template>
  <div v-gl-tooltip.hover :title="description">
    <gl-icon :size="12" :name="severityIcon" :class="severityClass" />
  </div>
</template>
