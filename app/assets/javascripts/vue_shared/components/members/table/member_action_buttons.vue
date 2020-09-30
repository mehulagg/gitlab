<script>
import { kebabCase } from 'lodash';
import UserActionButtons from '../action_buttons/user_action_buttons.vue';
import GroupActionButtons from '../action_buttons/group_action_buttons.vue';
import InviteActionButtons from '../action_buttons/invite_action_buttons.vue';
import AccessRequestActionButtons from '../action_buttons/access_request_action_buttons.vue';

export default {
  name: 'MemberActionButtons',
  components: {
    UserActionButtons,
    GroupActionButtons,
    InviteActionButtons,
    AccessRequestActionButtons,
  },
  props: {
    member: {
      type: Object,
      required: true,
    },
    memberType: {
      type: String,
      required: true,
    },
    permissions: {
      type: Object,
      required: true,
    },
    isCurrentUser: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    actionButtonComponent() {
      // eslint-disable-next-line @gitlab/require-i18n-strings
      return `${kebabCase(this.memberType)}-action-buttons`;
    },
  },
};
</script>

<template>
  <component
    :is="actionButtonComponent"
    :member="member"
    :permissions="permissions"
    :is-current-user="isCurrentUser"
  />
</template>
