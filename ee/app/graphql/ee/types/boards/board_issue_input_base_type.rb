# frozen_string_literal: true

module EE
  module Types
    module Boards
      module BoardIssueInputBaseType
        extend ActiveSupport::Concern

        prepended do
          argument :epic_id, GraphQL::ID_TYPE,
                   required: false,
                   description: 'Filter by epic ID. Incompatible with epicWildcardId'

          argument :weight, GraphQL::STRING_TYPE,
                   required: false,
                   description: 'Filter by weight'
        end
      end
    end
  end
end
