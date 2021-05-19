# frozen_string_literal: true

module ApprovalRules
  class ExternalApprovalRulePayloadWorker
    include ApplicationWorker

    sidekiq_options retry: 3
    idempotent!

    feature_category :source_code_management
    tags :exclude_from_kubernetes

    def perform(rule_id, data)
      rule = MergeRequests::ExternalStatusCheck.find(rule_id)

      ExternalStatusChecks::DispatchService.new(rule, data).execute
    end
  end
end
