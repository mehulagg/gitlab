# frozen_string_literal: true
module Security
  class CreateOrchestrationPolicyWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include CronjobQueue

    feature_category :vulnerability_management
    worker_resource_boundary :cpu

    def perform
      Security::OrchestrationPolicyConfiguration.find_in_batches do |configurations|
        configurations.each do |configuration|
          configuration.active_policies.each do |(policy_path, policy)|
            Security::OrchestrationPolicies::ProcessRuleService
              .new(configuration, policy_path, policy)
              .execute
          end
        end
      end
    end
  end
end
