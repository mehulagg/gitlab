import { __, n__, s__ } from '~/locale';

const CLICK_BUTTON = 'click_button';

export const EXPERIMENT_KEY = 'highlight_paid_features_during_active_trial';
export const RESIZE_EVENT_DEBOUNCE_MS = 150;
export const POPOVER_OR_TOOLTIP_BREAKPOINT = 'xs';

export const BADGE = {
  i18n: {
    title: {
      generic: __('This feature is part of your GitLab Ultimate trial.'),
      specific: __('The %{featureName} feature is part of your GitLab Ultimate trial.'),
    },
  },
  trackingEvents: {
    displayBadge: { action: 'display_badge', label: 'feature_highlight_badge' },
  },
};

export const POPOVER = {
  i18n: {
    buttons: {
      comparePlans: s__('BillingPlans|Compare all plans'),
      upgrade: s__('BillingPlans|Upgrade to GitLab %{planNameForUpgrade}'),
    },
    content: s__(`FeatureHighlight|Enjoying your GitLab %{planNameForTrial} trial? To continue
        using %{featureName} after your trial ends, upgrade to GitLab %{planNameForUpgrade}.`),
    defaultImgAltText: __('SVG illustration'),
    title: {
      countableTranslator(count) {
        return n__(
          'FeatureHighlight|%{daysRemaining} day remaining to enjoy %{featureName}',
          'FeatureHighlight|%{daysRemaining} days remaining to enjoy %{featureName}',
          count,
        );
      },
    },
  },
  trackingEvents: {
    popoverShown: { action: 'popover_shown', label: 'feature_highlight_popover' },
    upgradeBtnClick: { action: CLICK_BUTTON, label: 'upgrade_to_ultimate' },
    compareBtnClick: { action: CLICK_BUTTON, label: 'compare_all_plans' },
  },
};
