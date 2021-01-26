# frozen_string_literal: true

module TrialStatusWidgetHelper
  def eligible_for_trial_status_widget_experiment?(group)
    group.trial_active?
  end

  def show_trial_status_widget?(group)
    return false unless ::Gitlab::CurrentSettings.should_check_namespace_plan?
    return false unless experiment_enabled?(:show_trial_status_in_sidebar, subject: group)

    eligible_for_trial_status_widget_experiment?(group)
  end

  def trial_days_remaining_in_words(group)
    num_of_days = group.trial_days_remaining
    plan_title = group.gitlab_subscription&.plan_title

    ns_(
      "Trials|%{plan} Trial %{en_dash} %{num} day left",
      "Trials|%{plan} Trial %{en_dash} %{num} days left",
      num_of_days
    ) % { plan: plan_title, num: num_of_days, en_dash: '–' }
  end
end
