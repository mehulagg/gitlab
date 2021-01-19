import Vue from 'vue';
import ZenMode from '~/zen_mode';
import initIssuableSidebar from '~/init_issuable_sidebar';
import ShortcutsIssuable from '~/behaviors/shortcuts/shortcuts_issuable';
import { handleLocationHash } from '~/lib/utils/common_utils';
import initPipelines from '~/commit/pipelines/pipelines_bundle';
import initSourcegraph from '~/sourcegraph';
import loadAwardsHandler from '~/awards_handler';
import initInviteMemberTrigger from '~/invite_member/init_invite_member_trigger';
import initInviteMemberModal from '~/invite_member/init_invite_member_modal';
import StatusBox from '~/merge_request/components/status_box.vue';
import initRevertCommitModal from '~/projects/commit/init_revert_commit_modal';

export default function () {
  new ZenMode(); // eslint-disable-line no-new
  initIssuableSidebar();
  initPipelines();
  new ShortcutsIssuable(true); // eslint-disable-line no-new
  handleLocationHash();
  initSourcegraph();
  loadAwardsHandler();
  initInviteMemberModal();
  initInviteMemberTrigger();
  initRevertCommitModal();

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
