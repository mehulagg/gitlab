import $ from 'jquery';
import Vue from 'vue';
import BindInOut from '~/behaviors/bind_in_out';
import Group from '~/group';
import GroupPathValidator from './group_path_validator';
import initFilePickers from '~/file_pickers';
import InviteTeammates from '~/groups/components/invite_teammates.vue';

const parentId = $('#group_parent_id');
if (!parentId.val()) {
  new GroupPathValidator(); // eslint-disable-line no-new
}
BindInOut.initAll();
initFilePickers();

new Group(); // eslint-disable-line no-new

function mountInviteTeammates() {
  const el = document.querySelector('.js-invite-teammates');

  if (!el) return null;

  return new Vue({
    el,
    render(createElement) {
      return createElement(InviteTeammates, {
        props: {
          emails: JSON.parse(el.dataset.emails),
        },
      });
    },
  });
}

mountInviteTeammates();

