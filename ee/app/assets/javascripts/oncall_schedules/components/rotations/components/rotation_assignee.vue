<script>
import { GlAvatar, GlPopover } from '@gitlab/ui';
import { uniqueId } from 'lodash';
import { formatDate } from '~/lib/utils/datetime_utility';
import { truncate } from '~/lib/utils/text_utility';
import { __, sprintf } from '~/locale';

export const SHIFT_WIDTHS = {
  md: 140,
  sm: 90,
  xs: 40,
};

const ROTATION_CENTER_CLASS = 'gl-display-flex gl-justify-content-center gl-align-items-center';

export default {
  ROTATION_CENTER_CLASS,
  components: {
    GlAvatar,
    GlPopover,
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
      required: true,
    },
  },
  computed: {
    assigneeName() {
      if (this.shiftWidth <= SHIFT_WIDTHS.sm) {
        return truncate(this.assignee.user.username, 3);
      }

      return this.assignee.user.username;
    },
    chevronClass() {
      return `gl-bg-data-viz-${this.assignee.colorPalette}-${this.assignee.colorWeight}`;
    },
    endsAt() {
      return sprintf(__('Ends: %{endsAt}'), {
        endsAt: formatDate(this.rotationAssigneeEndsAt, 'mmmm d, yyyy, h:MMtt Z'),
      });
    },
    rotationAssigneeUniqueID() {
      return uniqueId('rotation-assignee-');
    },
    rotationMobileView() {
      return this.shiftWidth <= SHIFT_WIDTHS.xs;
    },
    startsAt() {
      return sprintf(__('Starts: %{startsAt}'), {
        startsAt: formatDate(this.rotationAssigneeStartsAt, 'mmmm d, yyyy, h:MMtt Z'),
      });
    },
  },
};
</script>

<template>
  <div class="gl-absolute gl-h-7 gl-mt-3" :style="rotationAssigneeStyle">
    <div
      :id="rotationAssigneeUniqueID"
      class="gl-h-6"
      :class="[chevronClass, $options.ROTATION_CENTER_CLASS]"
      data-testid="rotation-assignee"
    >
      <div class="gl-text-white" :class="$options.ROTATION_CENTER_CLASS">
        <gl-avatar :src="assignee.user.avatarUrl" :size="16" />
        <span v-if="!rotationMobileView" class="gl-ml-2" data-testid="rotation-assignee-name">{{
          assigneeName
        }}</span>
      </div>
    </div>
    <gl-popover
      :target="rotationAssigneeUniqueID"
      :title="assignee.user.username"
      triggers="hover"
      placement="top"
    >
      <p class="gl-m-0" data-testid="rotation-assignee-starts-at">{{ startsAt }}</p>
      <p class="gl-m-0" data-testid="rotation-assignee-ends-at">{{ endsAt }}</p>
    </gl-popover>
  </div>
</template>
