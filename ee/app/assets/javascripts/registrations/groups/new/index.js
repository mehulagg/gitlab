import Vue from 'vue';
import mountInviteMembers from 'ee/groups/invite';
import 'ee/pages/trials/country_select';
import { STEPS, ONBOARDING_ISSUES_EXPERIMENT_FLOW_STEPS } from '../../constants';
import ProgressBar from '../../components/progress_bar.vue';
import RegistrationTrialToggle from '../../components/registration_trial_toggle.vue';
import VisibilityLevelDropdown from '../../components/visibility_level_dropdown.vue';

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

function toggleTrialForm(trial) {
  const form = document.querySelector('.js-trial-form');
  const fields = document.querySelectorAll('.js-trial-field');

  if (!form) return null;

  form.classList.toggle('hidden', !trial);
  fields.forEach(f => {
    f.disabled = !trial; // eslint-disable-line no-param-reassign
  });

  return trial;
}

function mountTrialToggle() {
  const el = document.querySelector('.js-trial-toggle');

  if (!el) return null;

  const { active } = el.dataset;

  return new Vue({
    el,
    render(createElement) {
      return createElement(RegistrationTrialToggle, {
        props: { active },
        on: {
          changed: event => toggleTrialForm(event.trial),
        },
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

export default () => {
  mountProgressBar();
  mountVisibilityLevelDropdown();
  mountInviteMembers();
  mountTrialToggle();
};
