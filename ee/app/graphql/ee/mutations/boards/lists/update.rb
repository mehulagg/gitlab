# frozen_string_literal: true

module EE
  module Mutations
    module Boards
      module Lists
        module Update
          extend ActiveSupport::Concern

          prepended do
            argument :max_issue_count, GraphQL::INT_TYPE,
                     required: false,
                     description: 'Maximum number of issues in the list'

            argument :max_issue_weight, GraphQL::INT_TYPE,
                     required: false,
                     description: 'Maximum weight of issues in the list'
          end
        end
      end
    end
  end
end
