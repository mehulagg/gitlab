import Vue from 'vue';
import PaidFeatureCalloutBadge from './components/paid_feature_callout_badge.vue';
import PaidFeatureCalloutPopover from './components/paid_feature_callout_popover.vue';

export const initPaidFeatureCalloutBadge = () => {
  const el = document.getElementById('js-paid-feature-badge');

  if (!el) return undefined;

  const { ...props } = el.dataset;

  return new Vue({
    el,
    render: (createElement) => createElement(PaidFeatureCalloutBadge, { props }),
  });
};

export const initPaidFeatureCalloutPopover = () => {
  const el = document.getElementById('js-paid-feature-popover');

  if (!el) return undefined;

  const { daysRemaining, ...props } = el.dataset;

  return new Vue({
    el,
    render: (createElement) =>
      createElement(PaidFeatureCalloutPopover, {
        props: {
          daysRemaining: Number(daysRemaining),
          ...props,
        },
      }),
  });
};

export const initPaidFeatureCalloutBadgeAndPopover = () => {
  return {
    badge: initPaidFeatureCalloutBadge(),
    popover: initPaidFeatureCalloutPopover(),
  };
};
