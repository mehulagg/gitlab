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
    num_of_days = trial_days_remaining(group)
    plan_title = group.gitlab_subscription&.plan_title

    ns_(
      "Trials|%{plan} Trial %{en_dash} %{num} day left",
      "Trials|%{plan} Trial %{en_dash} %{num} days left",
      num_of_days
    ) % { plan: plan_title, num: num_of_days, en_dash: '–' }
  end

  def trial_days_remaining(group)
    (group.trial_ends_on - Date.current).to_i
  end

  def total_trial_duration(group)
    (group.trial_ends_on - group.trial_starts_on).to_i
  end

  def trial_days_used(group)
    total_trial_duration(group) - trial_days_remaining(group)
  end

  # A value between 0 & 100 rounded to 2 decimal places
  def trial_percentage_complete(group)
    (trial_days_used(group) / total_trial_duration(group).to_f * 100).round(2)
  end
end
