import Vue from 'vue';
import TrialStatusPopover from './components/trial_status_popover.vue';
import TrialStatusWidget from './components/trial_status_widget.vue';

export const initTrialStatusWidget = () => {
  const el = document.getElementById('js-trial-status-widget');

  if (!el) return undefined;

  const { daysRemaining, percentageComplete, ...props } = el.dataset;

  return new Vue({
    el,
    render: (createElement) =>
      createElement(TrialStatusWidget, {
        props: {
          ...props,
          daysRemaining: Number(daysRemaining),
          percentageComplete: Number(percentageComplete),
        },
      }),
  });
};

export const initTrialStatusPopover = () => {
  const el = document.getElementById('js-trial-status-popover');

  if (!el) return undefined;

  const { trialEndDate, ...props } = el.dataset;

  return new Vue({
    el,
    render: (createElement) =>
      createElement(TrialStatusPopover, {
        props: {
          ...props,
          trialEndDate: new Date(trialEndDate),
        },
      }),
  });
};

export const initTrialStatusWidgetAndPopover = () => {
  return {
    widget: initTrialStatusWidget(),
    popover: initTrialStatusPopover(),
  };
};
