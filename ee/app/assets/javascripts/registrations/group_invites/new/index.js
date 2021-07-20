import Vue from 'vue';
import inviteMembersForm from '../../components/invite_members_form.vue';
import ProgressBar from '../../components/progress_bar.vue';
import { STEPS, SIGNUP_ONBOARDING_FLOW_STEPS } from '../../constants';

function loadProgressBar() {
  const el = document.getElementById('progress-bar');

  if (!el) {
    return null;
  }

  return new Vue({
    el,
    render(createElement) {
      return createElement(ProgressBar, {
        props: { steps: SIGNUP_ONBOARDING_FLOW_STEPS, currentStep: STEPS.yourGroup },
      });
    },
  });
}

function loadInviteMembersForm() {
  const el = document.querySelector('.js-invite-group-members');

  if (!el) {
    return null;
  }

  const { endpoint, emails, docsPath } = el.dataset;

  return new Vue({
    el,
    provide: { endpoint },
    render(createElement) {
      return createElement(inviteMembersForm, {
        props: {
          emails: JSON.parse(emails),
          docsPath,
        },
      });
    },
  });
}

export default () => {
  loadProgressBar();
  loadInviteMembersForm();
};
