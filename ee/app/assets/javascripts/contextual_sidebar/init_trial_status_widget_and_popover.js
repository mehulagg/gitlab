import Vue from 'vue';
import TrialStatusPopover from './components/trial_status_popover.vue';
import TrialStatusWidget from './components/trial_status_widget.vue';

export const initTrialStatusWidget = () => {
  const el = document.getElementById('js-trial-status-widget');

  if (!el) return undefined;

  const {
    containerId,
    daysRemaining,
    navIconImagePath,
    percentageComplete,
    planName,
    plansHref,
  } = el.dataset;

  return new Vue({
    el,
    render: (createElement) =>
      createElement(TrialStatusWidget, {
        props: {
          containerId,
          daysRemaining: Number(daysRemaining),
          navIconImagePath,
          percentageComplete: Number(percentageComplete),
          planName,
          plansHref,
        },
      }),
  });
};

export const initTrialStatusPopover = () => {
  const el = document.getElementById('js-trial-status-popover');

  if (!el) return undefined;

  const {
    containerId,
    groupName,
    planName,
    plansHref,
    purchaseHref,
    targetId,
    trialEndDate,
  } = el.dataset;

  return new Vue({
    el,
    render: (createElement) =>
      createElement(TrialStatusPopover, {
        props: {
          containerId,
          groupName,
          planName,
          plansHref,
          purchaseHref,
          targetId,
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
