import Vue from 'vue';
import TrialStatusWidget from './components/trial_status_widget.vue';

export default () => {
  const el = document.getElementById('js-trial-status-widget');

  if (!el) return undefined;

  const { percentageComplete } = el.dataset;

  return new Vue({
    el,
    render: (createElement) =>
      createElement(TrialStatusWidget, {
        props: {
          ...el.dataset,
          percentageComplete: Number(percentageComplete),
        },
      }),
  });
};
