# frozen_string_literal: true
module Security
  class CreateOrchestrationPolicyWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    # rubocop:disable Scalability/CronWorkerContext
    # This worker does not perform work scoped to a context
    include CronjobQueue
    # rubocop:enable Scalability/CronWorkerContext

    feature_category :security_orchestration
    worker_resource_boundary :cpu

    def perform
      Security::OrchestrationPolicyConfiguration.with_outdated_configuration.find_in_batches do |configurations|
        configurations.each do |configuration|
          configuration.active_policies.each.with_index do |policy, policy_index|
            Security::OrchestrationPolicies::ProcessRuleService
              .new(configuration, policy_index, policy)
              .execute
          end
        end
      end
    end
  end
end
