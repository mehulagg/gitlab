<script>
import { GlToken, GlAvatarLabeled, GlTooltipDirective, GlPopover } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import { assigneeScheduleDateStart } from '../../../utils/common_utils';

export default {
  components: {
    GlToken,
    GlAvatarLabeled,
    GlPopover,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    assigneeIndex: {
      type: Number,
      required: true,
    },
    rotation: {
      type: Object,
      required: true,
    },
  },
  computed: {
    assignee() {
      return this.rotation.participants.nodes[this.assigneeIndex];
    },
    startsAt() {
      const startsAt = assigneeScheduleDateStart(
        new Date(this.rotation.startsAt),
        this.rotation.length * 7 * this.assigneeIndex,
      ).toLocaleString();
      // eslint-disable-next-line @gitlab/require-i18n-strings
      return sprintf(__('Starts at %{startsAt}'), { startsAt });
    },
    endsAt() {
      const endsAt = assigneeScheduleDateStart(
        new Date(this.rotation.startsAt),
        this.rotation.length * 7 * this.assigneeIndex + this.rotation.length * 7,
      ).toLocaleString();
      // eslint-disable-next-line @gitlab/require-i18n-strings
      return sprintf(__('Ends at %{endsAt}'), { endsAt });
    },
  },
};
</script>

<template>
  <div class="gl-f-full gl-mt-3 gl-px-3">
    <gl-token
      :id="assignee.user.id"
      :category-palette="assignee.colorPalette"
      :category-weight="assignee.colorWeight"
      class="gl-w-full gl-align-items-center"
    >
      <gl-avatar-labeled
        v-gl-tooltip="{ placement: 'bottom' }"
        class="gl-text-white"
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
      placement="top"
    >
      <p class="gl-m-0" data-testid="rotation-assignee-starts-at">{{ startsAt }}</p>
      <p class="gl-m-0" data-testid="rotation-assignee-ends-at">{{ endsAt }}</p>
    </gl-popover>
  </div>
</template>
