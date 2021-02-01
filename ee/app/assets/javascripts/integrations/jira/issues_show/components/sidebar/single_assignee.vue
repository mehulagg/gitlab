<script>
import AssigneeAvatarLink from '~/sidebar/components/assignees/assignee_avatar_link.vue';
import CollapsedAssignee from '~/sidebar/components/assignees/collapsed_assignee.vue';

export default {
  components: {
    AssigneeAvatarLink,
    CollapsedAssignee,
  },
  props: {
    user: {
      type: Object,
      required: true,
    },
    collapsed: {
      type: Boolean,
      required: false,
      default: false,
    },
    issuableType: {
      type: String,
      default: 'issue',
      required: false,
    },
  },
};
</script>
<template>
  <div>
    <collapsed-assignee v-if="collapsed" :user="user" />
    <assignee-avatar-link
      v-if="!collapsed"
      tooltip-placement="left"
      :tooltip-has-name="false"
      :user="user"
      :issuable-type="issuableType"
    >
      <div class="gl-ml-3 gl-line-height-normal">
        <div>{{ user.name }}</div>
        <slot name="username">
          <div>@{{ user.username }}</div>
        </slot>
      </div>
    </assignee-avatar-link>
  </div>
</template>
