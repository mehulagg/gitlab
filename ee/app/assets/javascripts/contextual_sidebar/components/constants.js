import { n__, s__ } from '~/locale';

const CLICK_BUTTON = 'click_button';
const RESIZE_EVENT_DEBOUNCE_MS = 150;

export const RESIZE = 'resize';
export const TRACKING_PROPERTY = 'experiment:show_trial_status_in_sidebar';

export const WIDGET = {
  i18n: {
    // Another hack to get around the absence of Nn__ in the javascript locale helpers.
    // See https://gitlab.com/gitlab-org/gitlab/-/merge_requests/61857/diffs#4cd858e386dcb3c7c8ba9944c52742abfc3f1241_0_31 for a different approach.
    widgetTitle: {
      singular: n__(
        'Trials|%{planName} Trial %{enDash} %{num} day left',
        'Trials|%{planName} Trial %{enDash} %{num} days left',
        1,
      ),
      plural: n__(
        'Trials|%{planName} Trial %{enDash} %{num} day left',
        'Trials|%{planName} Trial %{enDash} %{num} days left',
        2,
      ),
    },
  },
  trackingEvents: {
    widgetClick: { action: 'click_link', label: 'trial_status_widget' },
  },
};

export const POPOVER = {
  i18n: {
    compareAllButtonTitle: s__('Trials|Compare all plans'),
    popoverTitle: s__('Trials|Hey there'),
    popoverContent: s__(`Trials|Your trial ends on
      %{boldStart}%{trialEndDate}%{boldEnd}. We hope you’re enjoying the
      features of GitLab %{planName}. To keep those features after your trial
      ends, you’ll need to buy a subscription. (You can also choose GitLab
      Premium if it meets your needs.)`),
    upgradeButtonTitle: s__('Trials|Upgrade %{groupName} to %{planName}'),
  },
  trackingEvents: {
    popoverShown: { action: 'popover_shown', label: 'trial_status_popover' },
    upgradeBtnClick: { action: CLICK_BUTTON, label: 'upgrade_to_ultimate' },
    compareBtnClick: { action: CLICK_BUTTON, label: 'compare_all_plans' },
  },
  resizeEventDebounceMS: RESIZE_EVENT_DEBOUNCE_MS,
  disabledBreakpoints: ['xs', 'sm'],
  trialEndDateFormatString: 'mmmm d',
};
