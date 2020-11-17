# frozen_string_literal: true

module EE
  module API
    module Entities
      # Being used in private MR-level approvals API.
      # This overrides the `eligible_approvers` to be exposed as `approvers`.
      #
      # To be removed in https://gitlab.com/gitlab-org/gitlab/issues/13574.
      class MergeRequestApprovalSettingRule < MergeRequestApprovalStateRule
        expose :approvers, using: ::API::Entities::UserBasic, override: true
        expose :commented_approvers, as: :commented_by, using: ::API::Entities::UserBasic
      end
    end
  end
end
