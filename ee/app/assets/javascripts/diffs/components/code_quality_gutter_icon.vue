<script>
import { GlTooltipDirective, GlIcon } from '@gitlab/ui';
import { mapState } from 'vuex';
import { SEVERITY_CLASSES, SEVERITY_ICONS } from '~/reports/codequality_report/constants';

export default {
  components: {
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    filePath: {
      type: String,
      required: true,
    },
    line: {
      type: Object,
      required: true,
    },
  },
  computed: {
    ...mapState('diffs', ['codequalityDiff']),
    severityClass() {
      return SEVERITY_CLASSES[this.codequalityDiffForLine[0].severity] || SEVERITY_CLASSES.unknown;
    },
    severityIcon() {
      return SEVERITY_ICONS[this.codequalityDiffForLine[0].severity] || SEVERITY_ICONS.unknown;
    },
    codequalityDiffForLine() {
      const codequalityDiffForFile = this.codequalityDiff?.files?.[this.filePath] || [];

      return codequalityDiffForFile.filter(
        (violation) =>
          (this.line.left && violation.line === this.line.left.new_line) ||
          (this.line.right && violation.line === this.line.right.new_line),
      );
    },
  },
};
</script>

<template>
  <div
    v-if="codequalityDiffForLine.length"
    v-gl-tooltip.hover
    :title="codequalityDiffForLine.length ? codequalityDiffForLine[0].description : ''"
  >
    <gl-icon :size="12" :name="severityIcon" :class="severityClass" />
  </div>
</template>
