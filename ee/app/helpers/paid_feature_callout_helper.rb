# frozen_string_literal: true

# NOTE: This is largely mimicking the structure created as part of the
# TrialStatusWidgetHelper (ee/app/helpers/trial_status_widget_helper.rb).
module PaidFeatureCalloutHelper
  def run_highlight_paid_features_during_active_trial_experiment(group, &block)
    experiment(:highlight_paid_features_during_active_trial, group: group) do |e|
      e.exclude! unless billing_plans_and_trials_available?
      e.exclude! unless group && eligible_for_trial_upgrade_callout?(group)
      e.use { nil } # control gets nothing new added to the existing UI
      e.try(&block)
    end
  end

  def paid_feature_badge_data_attrs(feature:)
    paid_feature_callout_common_data_attrs(feature)
  end

  def paid_feature_popover_data_attrs(group:, feature:, promo_image_path: nil)
    base_attrs = paid_feature_callout_common_data_attrs(feature)
    base_attrs.merge(
      days_remaining: group.trial_days_remaining,
      href_compare_plans: group_billings_path(group),
      href_upgrade_to_paid: premium_subscription_path_for_group(group),
      plan_name_for_trial: group.gitlab_subscription&.plan_title,
      plan_name_for_upgrade: 'Premium',
      promo_image_path: promo_image_path,
      target_id: base_attrs[:container_id]
    )
  end

  private

  def paid_feature_callout_common_data_attrs(feature)
    {
      container_id: "#{feature.parameterize}-callout",
      feature_name: feature
    }
  end

  def premium_subscription_path_for_group(group)
    # Hard-coding the plan_id to the Premium plan on production & staging
    new_subscriptions_path(namespace_id: group.id, plan_id: '2c92c0f876e0f4cc0176e176a08f1b70')
  end
end
