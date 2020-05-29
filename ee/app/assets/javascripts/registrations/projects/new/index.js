import Vue from 'vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import {
  STEPS,
  ONBOARDING_ISSUES_EXPERIMENT_FLOW_STEPS,
  ONBOARDING_ISSUES_EXPERIMENT_AND_SUBSCRIPTION_FLOW_STEPS,
} from '../../constants';
import ProgressBar from '../../components/progress_bar.vue';

export default () => {
  const el = document.getElementById('progress-bar');

  if (!el) return null;

  const isInSubscriptionFlow = parseBoolean(el.dataset.isInSubscriptionFlow);

  const steps = isInSubscriptionFlow
    ? ONBOARDING_ISSUES_EXPERIMENT_AND_SUBSCRIPTION_FLOW_STEPS
    : ONBOARDING_ISSUES_EXPERIMENT_FLOW_STEPS;

  return new Vue({
    el,
    render(createElement) {
      return createElement(ProgressBar, {
        props: { steps, currentStep: STEPS.yourProject },
      });
    },
  });
};
