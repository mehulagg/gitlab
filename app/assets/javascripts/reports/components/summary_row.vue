<script>
import { GlLoadingIcon } from '@gitlab/ui';
import CiIcon from '~/vue_shared/components/ci_icon.vue';
import Popover from '~/vue_shared/components/help_popover.vue';
import { ICON_WARNING } from '../constants';

/**
 * Renders the summary row for each report
 *
 * Used both in MR widget and Pipeline's view for:
 * - Unit tests reports
 * - Security reports
 */

export default {
  name: 'ReportSummaryRow',
  components: {
    CiIcon,
    Popover,
    GlLoadingIcon,
  },
  props: {
    summary: {
      type: String,
      required: false,
      default: '',
    },
    statusIcon: {
      type: String,
      required: true,
    },
    popoverOptions: {
      type: Object,
      required: false,
      default: null,
    },
  },
  computed: {
    iconStatus() {
      return {
        group: this.statusIcon,
        icon: `status_${this.statusIcon}`,
      };
    },
    rowClasses() {
      return {
        'gl-bg-gray-10': this.statusIcon === ICON_WARNING,
      };
    },
  },
};
</script>
<template>
  <div class="gl-border-t-solid gl-border-t-gray-100 gl-border-t-1 gl-pl-7 gl-pr-3 gl-py-3 gl-display-flex gl-align-items-center" :class="rowClasses">
    <div class="gl-mr-3">
      <gl-loading-icon
        v-if="statusIcon === 'loading'"
        css-class="report-block-list-loading-icon"
        size="md"
      />
      <ci-icon v-else :status="iconStatus" :size="16" />
    </div>
    <div class="report-block-list-issue-description">
      <div
        class="report-block-list-issue-description-text"
        data-testid="test-summary-row-description"
      >
        <slot name="summary">{{ summary }}</slot
        ><span v-if="popoverOptions" class="text-nowrap"
          >&nbsp;<popover v-if="popoverOptions" :options="popoverOptions" class="align-top" />
        </span>
      </div>
    </div>
    <div
      v-if="$slots.default"
      class="text-right flex-fill d-flex justify-content-end flex-column flex-sm-row"
    >
      <slot></slot>
    </div>
  </div>
</template>
