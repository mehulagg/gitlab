# frozen_string_literal: true

module EE
  module API
    module Entities
      # Being used in private MR-level approvals API.
      # This overrides the `rules` to be exposed using MergeRequestApprovalSettingRule.
      #
      # To be removed in https://gitlab.com/gitlab-org/gitlab/issues/13574.
      class MergeRequestApprovalSettings < MergeRequestApprovalState
        expose :wrapped_approval_rules, as: :rules, using: MergeRequestApprovalSettingRule, override: true
      end
    end
  end
end
