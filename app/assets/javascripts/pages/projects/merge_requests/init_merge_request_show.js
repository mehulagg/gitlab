import Vue from 'vue';
import loadAwardsHandler from '~/awards_handler';
import ShortcutsIssuable from '~/behaviors/shortcuts/shortcuts_issuable';
import initIssuableSidebar from '~/init_issuable_sidebar';
import initInviteMemberModal from '~/invite_member/init_invite_member_modal';
import initInviteMemberTrigger from '~/invite_member/init_invite_member_trigger';
import { handleLocationHash } from '~/lib/utils/common_utils';
import StatusBox from '~/merge_request/components/status_box.vue';
import initSourcegraph from '~/sourcegraph';
import ZenMode from '~/zen_mode';

export default function initMergeRequestShow() {
  new ZenMode(); // eslint-disable-line no-new
  initIssuableSidebar();
  new ShortcutsIssuable(true); // eslint-disable-line no-new
  handleLocationHash();
  initSourcegraph();
  loadAwardsHandler();
  initInviteMemberModal();
  initInviteMemberTrigger();

  const el = document.querySelector('.js-mr-status-box');
  // eslint-disable-next-line no-new
  new Vue({
    el,
    render(h) {
      return h(StatusBox, {
        props: {
          initialState: el.dataset.state,
        },
      });
    },
  });
}
