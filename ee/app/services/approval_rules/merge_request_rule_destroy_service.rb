# frozen_string_literal: true

module ApprovalRules
  class MergeRequestRuleDestroyService < ::ApprovalRules::BaseService
    def initialize(approval_rule, user)
      @rule = approval_rule

      super(@rule.project, user, params)
    end

    def action
      @rule.destroy

      if @rule.destroyed?
        success
      else
        error(rule.errors.messages)
      end
    end

    def success
      merge_request_activity_counter
        .track_approval_rule_deleted_action(user: current_user)

      super
    end
  end
end
