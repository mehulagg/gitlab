import { __, n__, s__ } from '~/locale';

// TODO: Use these same strings in the Jest specs

export const RESIZE_EVENT_DEBOUNCE_MS = 150;

export const i18n = {
  popover: {
    content: s__(`FeatureHighlight|Enjoying your GitLab %{planNameForTrial} trial? To continue
    using %{featureName} after your trial ends, upgrade to GitLab %{planNameForUpgrade}.`),
    title(number) {
      return n__(
        'FeatureHighlight|%{daysRemaining} day remaining to enjoy %{featureName}',
        'FeatureHighlight|%{daysRemaining} days remaining to enjoy %{featureName}',
        number,
      );
    },
  },
  badge: {
    title: {
      generic: __('This feature is part of your GitLab Ultimate trial.'),
      specific: __('The %{featureName} feature is part of your GitLab Ultimate trial.'),
    },
  },
};
