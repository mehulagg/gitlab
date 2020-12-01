import Vue from 'vue';
import InviteTeammates from './components/invite_teammates.vue';

export default () => {
  const el = document.querySelector('.js-invite-teammates');

  if (!el) return null;

  return new Vue({
    el,
    render(createElement) {
      return createElement(InviteTeammates, {
        props: {
          emails: JSON.parse(el.dataset.emails),
          docsPath: el.dataset.docsPath,
        },
      });
    },
  });
};
