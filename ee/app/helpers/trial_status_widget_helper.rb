# frozen_string_literal: true

module TrialStatusWidgetHelper
  def show_trial_status_widget?(group)
    billing_plans_and_trials_available? &&
      trial_status_widget_experiment_enabled?(group) &&
      group.trial_active? &&
      user_can_administer_group?(group)
  end

  def plan_title_for_group(group)
    group.gitlab_subscription&.plan_title
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
