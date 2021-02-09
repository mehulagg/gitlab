# frozen_string_literal: true

module TrialStatusWidgetHelper
  def show_trial_status_widget?(group)
    billing_plans_and_trials_available? &&
      trial_status_widget_experiment_enabled?(group) &&
      group.trial_active? &&
      user_can_administer_group?(group)
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

  private

  def billing_plans_and_trials_available?
    ::Gitlab::CurrentSettings.should_check_namespace_plan?
  end

  def trial_status_widget_experiment_enabled?(group)
    experiment_enabled?(:show_trial_status_in_sidebar, subject: group)
  end

  def user_can_administer_group?(group)
    can?(current_user, :admin_namespace, group)
  end
end
