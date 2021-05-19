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
    <!-- TODO: add `gl-stroke-white` utility class to gitlab-ui so this icon can have a border -->
    <!-- TODO: figure out how to avoid squishing the border of the round icon -->
    <!-- TODO: add "severity: [severity]" to the tooltip -->
    <!-- TODO: use a popover instead of a tooltip if we need to display richer content? -->
    <!-- TODO: implement modal that opens on click to show details, make element look more clickable -->
    <gl-icon :size="12" :name="severityIcon" :class="severityClass" class="gl-stroke-white" />
  </div>
</template>
