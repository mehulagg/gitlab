# frozen_string_literal: true

module EE
  module Types
    module Issues
      module NegatedIssueFilterInputType
        extend ActiveSupport::Concern

        prepended do
          argument :epic_id, GraphQL::STRING_TYPE,
                   required: false,
                   description: 'ID of an epic not associated with the issues.'
          argument :weight, GraphQL::STRING_TYPE,
                   required: false,
                   description: 'Weight not applied to the issue.'
          argument :iteration_id, [::GraphQL::ID_TYPE],
                   required: false,
                   description: 'List of iteration Global IDs not applied to the issue.'
          argument :iteration_wildcard_id, ::Types::IterationWildcardIdEnum,
                   required: false,
                   description: 'Filter by negated iteration ID wildcard.'
        end
      end
    end
  end
end
