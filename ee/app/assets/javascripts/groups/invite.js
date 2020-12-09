import Vue from 'vue';
import InviteMembers from './components/invite_members.vue';

export default () => {
  const el = document.querySelector('.js-invite-members');

  if (!el) {
    return null;
  }

  const { emails, docsPath } = el.dataset;

  return new Vue({
    el,
    render(createElement) {
      return createElement(InviteMembers, {
        props: {
          emails: JSON.parse(emails),
          docsPath,
        },
      });
    },
  });
};
