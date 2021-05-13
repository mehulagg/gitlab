<script>
import { GlTooltipDirective, GlIcon } from '@gitlab/ui';
import { SEVERITY_CLASSES, SEVERITY_ICONS } from '~/reports/codequality_report/constants';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

export default {
  components: {
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    codequality: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  computed: {
    visible() {
      return this.glFeatures.codequalityMrDiffAnnotations && this.codequality.length > 0;
    },
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
  <div v-if="visible" v-gl-tooltip.hover :title="description">
    <gl-icon :size="12" :name="severityIcon" :class="severityClass" />
  </div>
</template>
