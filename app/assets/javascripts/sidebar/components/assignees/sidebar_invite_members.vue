<script>
import { GlLink } from '@gitlab/ui';
import InviteMemberModal from '~/invite_member/components/invite_member_modal.vue';
import InviteMemberTrigger from '~/invite_member/components/invite_member_trigger.vue';
import { __ } from '~/locale';

export default {
  displayText: __('Invite Members'),
  dataTrackLabel: 'edit_assignee',
  components: {
    GlLink,
    InviteMemberTrigger,
    InviteMemberModal,
  },
  inject: {
    projectMembersPath: {
      default: '',
    },
    directlyInviteMembers: {
      default: false,
    },
  },
};
</script>

<template>
  <div class="gl-pl-6!">
    <gl-link
      v-if="directlyInviteMembers"
      :to="projectMembersPath"
      target="_blank"
      data-track-event="click_invite_members"
      :data-track-label="$options.dataTrackLabel"
      >{{ $options.displayText }}</gl-link
    >
    <template v-else>
      <invite-member-trigger
        :display-text="$options.displayText"
        event="click_invite_members_version_b"
        :label="$options.dataTrackLabel"
      />
      <invite-member-modal :members-path="projectMembersPath" />
    </template>
  </div>
</template>
