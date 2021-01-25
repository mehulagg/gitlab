<script>
import { GlToken, GlAvatarLabeled, GlPopover } from '@gitlab/ui';
import { formatDate } from '~/lib/utils/datetime_utility';
import { __, sprintf } from '~/locale';

export default {
  components: {
    GlAvatarLabeled,
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
    endsAt() {
      return sprintf(__('Ends: %{endsAt}'), {
        endsAt: formatDate(this.rotationAssigneeEndsAt, 'mmmm d, yyyy, h:MMtt Z'),
      });
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
      :id="assignee.id"
      class="gl-w-full gl-h-6 gl-align-items-center"
      :class="chevronClass"
      :view-only="true"
    >
      <gl-avatar-labeled
        shape="circle"
        :size="16"
        :src="assignee.avatarUrl"
        :label="assignee.user.username"
        :title="assignee.user.username"
      />
    </gl-token>
    <gl-popover
      :target="assignee.id"
      :title="assignee.user.username"
      triggers="hover"
      placement="top"
    >
      <p class="gl-m-0" data-testid="rotation-assignee-starts-at">{{ startsAt }}</p>
      <p class="gl-m-0" data-testid="rotation-assignee-ends-at">{{ endsAt }}</p>
    </gl-popover>
  </div>
</template>
