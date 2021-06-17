<script>
import { GlTooltipDirective, GlIcon, GlModalDirective, GlModal } from '@gitlab/ui';
import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';
import { __, s__, sprintf } from '~/locale';
import CodequalityIssueBody from '~/reports/codequality_report/components/codequality_issue_body.vue';
import { SEVERITY_CLASSES, SEVERITY_ICONS } from '~/reports/codequality_report/constants';

const i18n = {
  tooltip: s__('CodeQuality|Code quality: %{severity} - %{description}'),
};

export default {
  components: {
    GlIcon,
    GlModal,
    CodequalityIssueBody,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
    GlModal: GlModalDirective,
  },
  modalCloseButton: {
    text: __('Close'),
    attributes: [{ variant: 'info' }],
  },
  i18n: {
    modalTitle: s__('CodeQuality|New code quality degradations on this line'),
  },
  props: {
    filePath: {
      type: String,
      required: true,
    },
    codequality: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  computed: {
    tooltipText() {
      return sprintf(i18n.tooltip, {
        severity: capitalizeFirstCharacter(this.severity),
        description: this.codequality[0].description,
      });
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
    line() {
      return this.codequality[0].line;
    },
    degradations() {
      return this.codequality.map((degradation) => {
        return {
          name: degradation.description,
          severity: degradation.severity,
          path: this.filePath,
          line: this.line,
        };
      });
    },
  },
};
</script>

<template>
  <div>
    <gl-icon
      v-gl-modal="`codequality-${filePath}:${line}`"
      v-gl-tooltip.hover
      :title="tooltipText"
      :size="12"
      :name="severityIcon"
      :class="severityClass"
      class="gl-hover-cursor-pointer codequality-severity-icon"
    />
    <gl-modal
      :modal-id="`codequality-${filePath}:${line}`"
      :title="$options.i18n.modalTitle"
      :action-primary="$options.modalCloseButton"
    >
      <codequality-issue-body
        v-for="(degradation, index) in degradations"
        :key="index"
        :issue="degradation"
      />
    </gl-modal>
  </div>
</template>
