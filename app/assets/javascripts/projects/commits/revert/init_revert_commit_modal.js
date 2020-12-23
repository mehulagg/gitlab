import Vue from 'vue';
import RevertCommitModal from './components/form_modal.vue';

export default function initInviteMembersModal() {
  const el = document.querySelector('.js-revert-commit-modal');
  if (!el) {
    return false;
  }

  const { title, path, startBranch, pushCode, branchCollaboration, targetBranch } = el.dataset;

  return new Vue({
    el,
    provide: { title, path, startBranch, targetBranch },
    render: createElement => createElement(RevertCommitModal, { props: { pushCode, branchCollaboration } }),
  });
}
