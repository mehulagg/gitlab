# frozen_string_literal: true

module TrialStatusWidgetHelper
  def trial_status_popover_data_attrs(group)
    base_attrs = trial_status_common_data_attrs(group)
    base_attrs.merge(
      group_name: group.name,
      purchase_href: ultimate_subscription_path_for_group(group),
      target_id: base_attrs[:container_id],
      trial_end_date: group.trial_ends_on
    )
  end

  def trial_status_widget_data_attrs(group)
    trial_status_common_data_attrs(group).merge(
      days_remaining: group.trial_days_remaining,
      nav_icon_image_path: image_path('illustrations/golden_tanuki.svg'),
      percentage_complete: group.trial_percentage_complete
    )
  end

  def show_trial_status_widget?(group)
    billing_plans_and_trials_available? && eligible_for_trial_upgrade_callout?(group)
  end

  private

  def billing_plans_and_trials_available?
    ::Gitlab::CurrentSettings.should_check_namespace_plan?
  end

  def eligible_for_trial_upgrade_callout?(group)
    group.trial_active? && can?(current_user, :admin_namespace, group)
  end

  def trial_status_common_data_attrs(group)
    {
      container_id: 'trial-status-sidebar-widget',
      plan_name: group.gitlab_subscription&.plan_title,
      plans_href: group_billings_path(group)
    }
  end

  def ultimate_subscription_path_for_group(group)
    # Hard-coding the plan_id to the Ultimate plan on production & staging
    new_subscriptions_path(namespace_id: group.id, plan_id: '2c92a0fc5a83f01d015aa6db83c45aac')
  end
end
