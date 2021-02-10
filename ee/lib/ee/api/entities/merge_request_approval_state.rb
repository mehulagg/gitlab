# frozen_string_literal: true

module EE
  module API
    module Entities
      class MergeRequestApprovalState < Grape::Entity
        expose :approval_rules_overwritten do |approval_state|
          approval_state.approval_rules_overwritten?
        end

        expose :wrapped_approval_rules, as: :rules, using: MergeRequestApprovalStateRule
      end
    end
  end
end
