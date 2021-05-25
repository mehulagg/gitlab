import Vue from 'vue';
import InviteMembersTrigger from '~/invite_members/components/invite_members_trigger.vue';

export default function initInviteMembersTrigger() {
  const triggers = document.querySelectorAll('.js-invite-members-trigger');

  if (!triggers) {
    return false;
  }

  return triggers.forEach((trigger) => {
    return new Vue({
      el: trigger,
      render: (createElement) =>
        createElement(InviteMembersTrigger, {
          props: {
            ...trigger.dataset,
          },
        }),
    });
  });
}
