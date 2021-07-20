import Vue from 'vue';
import PaidFeatureCalloutBadge from './components/paid_feature_callout_badge.vue';
import PaidFeatureCalloutPopover from './components/paid_feature_callout_popover.vue';

export const initPaidFeatureCalloutBadge = () => {
  const el = document.getElementById('js-paid-feature-badge');

  if (!el) return undefined;

  const { featureName, id } = el.dataset;

  return new Vue({
    el,
    render: (createElement) =>
      createElement(PaidFeatureCalloutBadge, { props: { featureName }, attrs: { id } }),
  });
};

export const initPaidFeatureCalloutPopover = () => {
  const el = document.getElementById('js-paid-feature-popover');

  if (!el) return undefined;

  const {
    containerId,
    daysRemaining,
    featureName,
    hrefComparePlans,
    hrefUpgradeToPaid,
    planNameForTrial,
    planNameForUpgrade,
    promoImageAltText,
    promoImagePath,
    targetId,
  } = el.dataset;

  return new Vue({
    el,
    render: (createElement) =>
      createElement(PaidFeatureCalloutPopover, {
        props: {
          containerId,
          daysRemaining: Number(daysRemaining),
          featureName,
          hrefComparePlans,
          hrefUpgradeToPaid,
          planNameForTrial,
          planNameForUpgrade,
          promoImageAltText,
          promoImagePath,
          targetId,
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
