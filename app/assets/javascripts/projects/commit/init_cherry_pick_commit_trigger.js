import Vue from 'vue';
import CommitFormTrigger from './components/form_trigger.vue';
import { OPEN_CHERRY_PICK_MODAL } from './constants';

export default function initInviteMembersTrigger() {
  const el = document.querySelector('.js-cherry-pick-commit-trigger');

  if (!el) {
    return false;
  }

  const { displayText } = el.dataset;

  return new Vue({
    el,
    provide: { displayText },
    render: (createElement) =>
      createElement(CommitFormTrigger, { props: { openModal: OPEN_CHERRY_PICK_MODAL } }),
  });
}
