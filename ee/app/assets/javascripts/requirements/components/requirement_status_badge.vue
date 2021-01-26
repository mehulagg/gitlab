<script>
import { GlBadge, GlIcon, GlTooltip } from '@gitlab/ui';
import { __ } from '~/locale';
import timeagoMixin from '~/vue_shared/mixins/timeago';

import { TestReportStatus } from '../constants';

export default {
  components: {
    GlBadge,
    GlIcon,
    GlTooltip,
  },
  mixins: [timeagoMixin],
  props: {
    testReport: {
      type: Object,
      required: true,
    },
    lastTestReportManuallyCreated: {
      type: Boolean,
      required: true,
    },
    elementType: {
      type: String,
      required: false,
      default: 'div',
    },
  },
  computed: {
    testReportBadge() {
      if (this.testReport.state === TestReportStatus.Passed) {
        return {
          variant: 'success',
          icon: 'status_success',
          text: __('satisfied'),
          tooltipTitle: __('Passed on'),
        };
      } else if (this.testReport.state === TestReportStatus.Failed) {
        return {
          variant: 'danger',
          icon: 'status_failed',
          text: __('failed'),
          tooltipTitle: __('Failed on'),
        };
      }
      return {
        variant: 'warning',
        icon: 'status_warning',
        text: __('missing'),
        tooltipTitle: '',
      };
    },
    hideTestReportBadge() {
      // User can manually indicate that a requirement has not been satisfied
      // Internally, we create a test report with FAILED state with null build_id
      // (this type of test report with null build id is said to be manually created).
      // In this case, we do not show 'failed' badge.
      return (
        this.testReport.state === TestReportStatus.Failed && this.lastTestReportManuallyCreated
      );
    },
  },
  methods: {
    getTestReportBadgeTarget() {
      return this.$refs.testReportBadge?.$el || '';
    },
  },
};
</script>

<template>
  <component :is="elementType" v-if="!hideTestReportBadge" class="requirement-status-badge">
    <gl-badge ref="testReportBadge" :variant="testReportBadge.variant">
      <gl-icon :name="testReportBadge.icon" class="mr-1" />
      {{ testReportBadge.text }}
    </gl-badge>
    <gl-tooltip
      v-if="testReportBadge.tooltipTitle"
      :target="getTestReportBadgeTarget"
      custom-class="requirement-status-tooltip"
    >
      <b>{{ testReportBadge.tooltipTitle }}</b>
      <div class="mt-1">{{ tooltipTitle(testReport.createdAt) }}</div>
    </gl-tooltip>
  </component>
</template>
