<script>
import { GlAvatarLink, GlAvatarLabeled, GlLink } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  milestone: 'milestone',
  iteration: 'iteration',
  assignee: 'assignee',
  labelMilestoneText: __('Milestone'),
  labelIterationText: __('Iteration'),
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
    activeListIteration() {
      return this.activeList.iteration;
    },
    listTypeTitle() {
      switch (this.boardListType) {
        case this.$options.milestone: {
          return this.$options.labelMilestoneText;
        }
        case this.$options.assignee: {
          return this.$options.labelAssigneeText;
        }
        case this.$options.iteration: {
          return this.$options.labelIterationText;
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
    <gl-link
      v-else-if="boardListType === $options.iteration"
      :href="activeListIteration.webUrl"
      >{{ activeListIteration.title }}</gl-link
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
