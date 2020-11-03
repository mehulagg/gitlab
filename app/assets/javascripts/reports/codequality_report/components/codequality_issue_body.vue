<script>
/**
 * Renders Code quality body text
 * Fixed: [name] in [link]:[line]
 */
import { GlBadge } from '@gitlab/ui';
import ReportLink from '~/reports/components/report_link.vue';
import { STATUS_SUCCESS } from '~/reports/constants';
import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';

const SEVERITY_VARIANTS = {
  info: 'info',
  minor: 'neutral',
  major: 'warning',
  critical: 'danger',
  blocker: 'danger',
};

export default {
  name: 'CodequalityIssueBody',
  components: {
    GlBadge,
    ReportLink,
  },
  props: {
    status: {
      type: String,
      required: true,
    },
    issue: {
      type: Object,
      required: true,
    },
  },
  computed: {
    isBlocker() {
      return this.issue.severity === 'blocker';
    },
    isStatusSuccess() {
      return this.status === STATUS_SUCCESS;
    },
    hasSeverity() {
      return Boolean(this.issue.severity) && Boolean(this.severityVariant);
    },
    severity() {
      return capitalizeFirstCharacter(this.issue.severity);
    },
    severityBadgeClasses() {
      return {
        'gl-font-weight-bold': this.isBlocker,
      };
    },
    severityIcon() {
      return this.isBlocker ? 'cancel' : null;
    },
    severityVariant() {
      return SEVERITY_VARIANTS[this.issue.severity];
    },
  },
};
</script>
<template>
  <div class="gl-display-flex gl-mt-2 gl-mb-2 gl-w-full">
    <div class="gl-mr-5 gl-w-12">
      <gl-badge
        v-if="hasSeverity"
        :class="severityBadgeClasses"
        :variant="severityVariant"
        :icon="severityIcon"
        >{{ severity }}</gl-badge
      >
    </div>
    <div class="gl-flex-fill-1">
      <div>
        <template v-if="isStatusSuccess">{{ s__('ciReport|Fixed:') }}</template>

        {{ issue.name }}
      </div>

      <report-link v-if="issue.path" :issue="issue" />
    </div>
  </div>
</template>
