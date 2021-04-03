import Vue from 'vue';
import ProgressBar from 'ee/registrations/components/progress_bar.vue';
import { STEPS, SUBSCRIPTON_FLOW_STEPS } from 'ee/registrations/constants';
import UserCallout from '~/user_callout';

export default () => {
  // eslint-disable-next-line no-new
  new UserCallout();

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
