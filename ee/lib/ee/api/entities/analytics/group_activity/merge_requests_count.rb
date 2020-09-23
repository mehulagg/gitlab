# frozen_string_literal: true

module EE
  module API
    module Entities
      module Analytics
        module GroupActivity
          class MergeRequestsCount < Grape::Entity
            expose :merge_requests_count
          end
        end
      end
    end
  end
end
