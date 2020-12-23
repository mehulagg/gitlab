import Vue from 'vue';
import RevertCommitTrigger from './components/form_trigger.vue';

export default function initInviteMembersTrigger() {
  const el = document.querySelector('.js-revert-commit-trigger');

  if (!el) {
    return false;
  }

  const { displayText } = el.dataset;

  return new Vue({
    el,
    provide: { displayText },
    render: createElement => createElement(RevertCommitTrigger),
  });
}
