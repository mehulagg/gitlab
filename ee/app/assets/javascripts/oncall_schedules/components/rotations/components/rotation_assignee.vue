<script>
import { GlToken, GlAvatar, GlPopover } from '@gitlab/ui';
import { formatDate } from '~/lib/utils/datetime_utility';
import { truncate } from '~/lib/utils/text_utility';
import { __, sprintf } from '~/locale';

export const SHIFT_WIDTHS = {
  md: 150,
  sm: 75,
  xs: 25,
};

export default {
  components: {
    GlAvatar,
    GlPopover,
    GlToken,
  },
  props: {
    assignee: {
      type: Object,
      required: true,
    },
    rotationAssigneeStartsAt: {
      type: String,
      required: true,
    },
    rotationAssigneeEndsAt: {
      type: String,
      required: true,
    },
    rotationAssigneeStyle: {
      type: Object,
      required: true,
    },
    shiftWidth: {
      type: Number,
      required: false,
      default: SHIFT_WIDTHS.md,
    },
  },
  computed: {
    chevronClass() {
      return `gl-bg-data-viz-${this.assignee.colorPalette}-${this.assignee.colorWeight}`;
    },
    startsAt() {
      return sprintf(__('Starts: %{startsAt}'), {
        startsAt: formatDate(this.rotationAssigneeStartsAt, 'mmmm d, yyyy, h:MMtt Z'),
      });
    },
    rotationRandomID() {
      return `${this.assignee.user.id}-${Math.random()}`;
    },
    endsAt() {
      return sprintf(__('Ends: %{endsAt}'), {
        endsAt: formatDate(this.rotationAssigneeEndsAt, 'mmmm d, yyyy, h:MMtt Z'),
      });
    },
    rotationMobileView() {
      return this.shiftWidth <= SHIFT_WIDTHS.xs;
    },
    assigneeName() {
      if (this.shiftWidth <= SHIFT_WIDTHS.sm) {
        return truncate(this.assignee.user.username, 3);
      }

      return this.assignee.user.username;
    },
  },
};
</script>

<template>
  <div
    class="gl-absolute gl-h-7 gl-mt-3 gl-z-index-1 gl-overflow-hidden"
    :style="rotationAssigneeStyle"
  >
    <gl-token
      :id="rotationRandomID"
      class="gl-w-full gl-h-6 gl-align-items-center"
      :class="chevronClass"
      :view-only="true"
    >
      <div class="gl-avatar-labeled-label gl-display-flex">
        <gl-avatar :src="assignee.avatarUrl" :size="16" class="gl-mr-2" />
        <span v-if="!rotationMobileView" data-testid="rotation-assignee-name">{{
          assigneeName
        }}</span>
      </div>
    </gl-token>
    <gl-popover
      :target="rotationRandomID"
      :title="assignee.user.username"
      triggers="hover"
      placement="left"
    >
      <p class="gl-m-0" data-testid="rotation-assignee-starts-at">{{ startsAt }}</p>
      <p class="gl-m-0" data-testid="rotation-assignee-ends-at">{{ endsAt }}</p>
    </gl-popover>
  </div>
</template>
