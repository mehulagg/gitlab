<script>
import { GlTooltipDirective, GlIcon } from '@gitlab/ui';

export default {
  name: 'StageTableHeader',
  components: {
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    headerClasses: {
      type: String,
      required: false,
      default: '',
    },
    title: {
      type: String,
      required: true,
    },
    tooltipTitle: {
      type: String,
      required: false,
      default: '',
    },
  },
};
</script>

<template>
  <li :class="headerClasses">
    <span class="stage-name gl-font-weight-bold">{{ title }}</span>
    <gl-icon
      v-gl-tooltip
      class="gl-vertical-align-middle"
      :size="14"
      name="question"
      container=".stage-name"
      :title="tooltipTitle"
    />
  </li>
</template>
