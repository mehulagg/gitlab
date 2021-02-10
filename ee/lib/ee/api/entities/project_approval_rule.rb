# frozen_string_literal: true

module EE
  module API
    module Entities
      class ProjectApprovalRule < ApprovalRule
        expose :protected_branches, using: ::API::Entities::ProtectedBranch, if: -> (rule, _) { rule.project.multiple_approval_rules_available? }
      end
    end
  end
end
