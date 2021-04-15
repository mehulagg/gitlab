import Vue from 'vue';
import PaidFeatureCalloutBadge from './components/paid_feature_callout_badge.vue';

export const initPaidFeatureCalloutBadge = () => {
  const el = document.getElementById('js-paid-feature-badge');

  if (!el) return undefined;

  return new Vue({
    el,
    render: (createElement) => createElement(PaidFeatureCalloutBadge),
  });
};
