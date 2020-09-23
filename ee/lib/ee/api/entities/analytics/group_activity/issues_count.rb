# frozen_string_literal: true

module EE
  module API
    module Entities
      module Analytics
        module GroupActivity
          class IssuesCount < Grape::Entity
            expose :issues_count
          end
        end
      end
    end
  end
end
