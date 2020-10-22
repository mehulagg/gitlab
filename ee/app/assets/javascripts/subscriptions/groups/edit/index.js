import Vue from 'vue';
import { STEPS, SUBSCRIPTON_FLOW_STEPS } from 'ee/registrations/constants';
import ProgressBar from 'ee/registrations/components/progress_bar.vue';

export default () => {
  const el = document.getElementById('progress-bar');

  if (!el) return null;

  return new Vue({
    el,
    render(createElement) {
      return createElement(ProgressBar, {
        props: { steps: SUBSCRIPTON_FLOW_STEPS, currentStep: STEPS.yourGroup },
      });
    },
  });
};
