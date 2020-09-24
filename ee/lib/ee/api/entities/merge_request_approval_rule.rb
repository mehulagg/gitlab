# frozen_string_literal: true

module EE
  module API
    module Entities
      class MergeRequestApprovalRule < ApprovalRule
        class SourceRule < Grape::Entity
          expose :approvals_required
        end

        expose :section
        expose :source_rule, using: MergeRequestApprovalRule::SourceRule
        expose :overridden?, as: :overridden
      end
    end
  end
end
