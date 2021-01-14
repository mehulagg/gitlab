import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
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
import getStateQuery from '~/merge_request/queries/get_state.query.graphql';

Vue.use(VueApollo);

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

  const el = document.querySelector('.js-mr-status-box');
  const apolloProvider = new VueApollo({ defaultClient: createDefaultClient() });
  // eslint-disable-next-line no-new
  new Vue({
    el,
    apolloProvider,
    provide: {
      query: getStateQuery,
      projectPath: el.dataset.projectPath,
      iid: el.dataset.iid,
    },
    render(h) {
      return h(StatusBox, {
        props: {
          initialState: el.dataset.state,
        },
      });
    },
  });
}
