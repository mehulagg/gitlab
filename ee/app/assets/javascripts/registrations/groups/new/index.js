import Vue from 'vue';
import mountInviteMembers from 'ee/groups/invite';
import mountVisibilityLevelDropdown from '~/groups/visibility_level';
import { STEPS, ONBOARDING_ISSUES_EXPERIMENT_FLOW_STEPS } from '../../constants';
import ProgressBar from '../../components/progress_bar.vue';

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

export default () => {
  mountProgressBar();
  mountVisibilityLevelDropdown();
  mountInviteMembers();
};
