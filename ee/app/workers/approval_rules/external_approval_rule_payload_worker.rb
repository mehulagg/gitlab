# frozen_string_literal: true

module ApprovalRules
  class ExternalApprovalRulePayloadWorker
    include ApplicationWorker
    idempotent!

    feature_category :source_code_management

    def perform(rule_id, data)
      rule = ApprovalRules::ExternalApprovalRule.find(rule_id)

      ExternalApprovalRules::DispatchService.new(rule, data).execute
    end
  end
end
