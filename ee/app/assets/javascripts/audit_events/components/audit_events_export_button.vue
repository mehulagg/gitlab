<script>
import { GlButton, GlTooltipDirective } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  components: {
    GlButton,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    exportHref: {
      required: true,
      type: String,
    },
  },
  strings: {
    buttonText: __('Export as CSV'),
    tooltipText: __('Max 100,000 events'),
  },
};
</script>

<template>
  <gl-button
    v-gl-tooltip.hover
    :href="exportHref"
    icon="export"
    :title="$options.strings.tooltipText"
  >
    {{ $options.strings.buttonText }}
  </gl-button>
</template>
