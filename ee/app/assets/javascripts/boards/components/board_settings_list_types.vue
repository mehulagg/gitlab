<script>
import { GlAvatarLink, GlAvatarLabeled, GlLink } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  milestone: 'milestone',
  assignee: 'assignee',
  labelMilestoneText: __('Milestone'),
  labelAssigneeText: __('Assignee'),
  components: {
    GlLink,
    GlAvatarLink,
    GlAvatarLabeled,
  },
  props: {
    boardListType: {
      type: String,
      required: true,
    },
    activeList: {
      type: Object,
      required: true,
    },
  },
  computed: {
    activeListAssignee() {
      return this.activeList.assignee;
    },
    activeListMilestone() {
      return this.activeList.milestone;
    },
    listTypeTitle() {
      switch (this.boardListType) {
        case this.$options.milestone: {
          return this.$options.labelMilestoneText;
        }
        case this.$options.assignee: {
          return this.$options.labelAssigneeText;
        }
        default: {
          return '';
        }
      }
    },
  },
};
</script>

<template>
  <div>
    <label class="js-list-label gl-display-block">{{ listTypeTitle }}</label>
    <gl-link
      v-if="boardListType === $options.milestone"
      class="js-milestone"
      :href="activeListMilestone.webUrl"
      >{{ activeListMilestone.title }}</gl-link
    >
    <gl-avatar-link
      v-else-if="boardListType === $options.assignee"
      class="js-assignee"
      :href="activeListAssignee.webUrl"
    >
      <gl-avatar-labeled
        :size="32"
        :label="activeListAssignee.name"
        :sub-label="`@${activeListAssignee.username}`"
        :src="activeListAssignee.avatar"
      />
    </gl-avatar-link>
  </div>
</template>
