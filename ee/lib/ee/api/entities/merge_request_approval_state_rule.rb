# frozen_string_literal: true

module EE
  module API
    module Entities
      class MergeRequestApprovalStateRule < MergeRequestApprovalRule
        expose :code_owner
        expose :approved_approvers, as: :approved_by, using: ::API::Entities::UserBasic
        expose :approved?, as: :approved
      end
    end
  end
end
