<script>
import { GlToken, GlAvatarLabeled, GlPopover } from '@gitlab/ui';
import { assigneeScheduleDateStart } from 'ee/oncall_schedules/utils/common_utils';
import { __, sprintf } from '~/locale';

export default {
  components: {
    GlToken,
    GlAvatarLabeled,
    GlPopover,
  },
  props: {
    assigneeIndex: {
      type: Number,
      required: true,
    },
    assignee: {
      type: Object,
      required: true,
    },
    rotationLength: {
      type: Number,
      required: true,
    },
    rotationStartsAt: {
      type: String,
      required: true,
    },
  },
  computed: {
    chevronClass() {
      return `gl-bg-data-viz-${this.assignee.colorPalette}-${this.assignee.colorWeight}`;
    },
    startsAt() {
      const startsAt = assigneeScheduleDateStart(
        new Date(this.rotationStartsAt),
        this.rotationLength * 7 * this.assigneeIndex,
      ).toLocaleString();
      return sprintf(__('Starts at %{startsAt}'), { startsAt });
    },
    endsAt() {
      const endsAt = assigneeScheduleDateStart(
        new Date(this.rotationStartsAt),
        this.rotationLength * 7 * this.assigneeIndex + this.rotationLength * 7,
      ).toLocaleString();
      return sprintf(__('Ends at %{endsAt}'), { endsAt });
    },
  },
};
</script>

<template>
  <div class="gl-w-full gl-mt-3 gl-px-3">
    <gl-token
      :id="assignee.user.id"
      class="gl-w-full gl-align-items-center"
      :class="chevronClass"
      :view-only="true"
    >
      <gl-avatar-labeled
        shape="circle"
        :size="16"
        :src="assignee.user.avatarUrl"
        :label="assignee.user.username"
        :title="assignee.user.username"
      />
    </gl-token>
    <gl-popover
      :target="assignee.user.id"
      :title="assignee.user.username"
      triggers="hover"
      placement="left"
    >
      <p class="gl-m-0" data-testid="rotation-assignee-starts-at">{{ startsAt }}</p>
      <p class="gl-m-0" data-testid="rotation-assignee-ends-at">{{ endsAt }}</p>
    </gl-popover>
  </div>
</template>
