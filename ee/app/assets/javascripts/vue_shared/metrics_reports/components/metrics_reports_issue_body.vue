<script>
import { GlBadge } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  name: 'MetricsReportsIssueBody',
  components: {
    GlBadge,
  },
  props: {
    issue: {
      type: Object,
      required: true,
      validator(obj) {
        return obj.name !== undefined && obj.value !== undefined;
      },
    },
  },
  computed: {
    shouldShowBadge() {
      return this.issue.isNew || this.issue.wasRemoved;
    },
    badgeText() {
      if (this.issue.isNew) {
        return __('New');
      }

      return __('Removed');
    },
    /*
     * If metric is new or removed, we do not need to show previous value
     */
    previousValue() {
      if (this.shouldShowBadge) {
        return '';
      }

      if (this.issue.previous_value) {
        return `(${this.issue.previous_value})`;
      }

      return __('(No changes)');
    },
  },
};
</script>
<template>
  <div class="report-block-list-issue-description">
    <div class="report-block-list-issue-description-text js-metrics-reports-issue-text">
      {{ issue.name }}: {{ issue.value }} {{ previousValue }}
    </div>
    <gl-badge v-if="shouldShowBadge" variant="info" class="js-metrics-reports-issue-badge">{{
      badgeText
    }}</gl-badge>
  </div>
</template>
