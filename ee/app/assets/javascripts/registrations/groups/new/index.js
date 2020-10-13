import Vue from 'vue';
import { STEPS, ONBOARDING_ISSUES_EXPERIMENT_FLOW_STEPS } from '../../constants';
import ProgressBar from '../../components/progress_bar.vue';
import VisibilityLevelDropdown from '../../components/visibility_level_dropdown.vue';
import InviteTeammates from '../../components/invite_teammates.vue';

function mountProgressBar() {
  const el = document.getElementById('progress-bar');

  if (!el) return null;

  return new Vue({
    el,
    render(createElement) {
      return createElement(ProgressBar, {
        props: { steps: ONBOARDING_ISSUES_EXPERIMENT_FLOW_STEPS, currentStep: STEPS.yourGroup },
      });
    },
  });
}

function mountVisibilityLevelDropdown() {
  const el = document.querySelector('.js-visibility-level-dropdown');

  if (!el) return null;

  return new Vue({
    el,
    render(createElement) {
      return createElement(VisibilityLevelDropdown, {
        props: {
          visibilityLevelOptions: JSON.parse(el.dataset.visibilityLevelOptions),
          defaultLevel: Number(el.dataset.defaultLevel),
        },
      });
    },
  });
}

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

export default () => {
  mountProgressBar();
  mountVisibilityLevelDropdown();
  mountInviteTeammates();
};
