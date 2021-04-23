# frozen_string_literal: true

module PaidFeatureCalloutHelper
  def run_highlight_paid_features_during_active_trial_experiment(group, &block)
    experiment(:highlight_paid_features_during_active_trial, group: group) do |e|
      e.exclude! unless billing_plans_and_trials_available?
      e.exclude! unless group && eligible_for_trial_upgrade_callout?(group)
      e.use { nil } # control gets nothing new added to the existing UI
      e.try(&block)
    end
  end
end
