# frozen_string_literal: true

module API
  module Entities
    module MergeRequests
      class StatusCheck < Grape::Entity
        expose :id
        expose :name
        expose :external_url
        expose :status

        def status
          object.approved?(options[:merge_request], options[:sha]) ? 'approved' : 'pending'
        end
      end
    end
  end
end
