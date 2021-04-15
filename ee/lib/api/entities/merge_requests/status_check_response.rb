# frozen_string_literal: true

module API
  module Entities
    module MergeRequests
      class StatusCheckResponse < Grape::Entity
        expose :id
        expose :merge_request, using: Entities::MergeRequest
        expose :external_approval_rule, using: Entities::ExternalApprovalRule
      end
    end
  end
end
