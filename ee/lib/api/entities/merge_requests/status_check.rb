# frozen_string_literal: true

module API
  module Entities
    module MergeRequests
      class StatusCheck < Grape::Entity # Passes in an ExternalApprovalRule and resolves down to a StatusCheck
        expose :id
        expose :name
        expose :external_url
        expose :status

        def status
          object.approved?(options[:merge_request]) ? 'approved' : 'pending'
        end
      end
    end
  end
end
