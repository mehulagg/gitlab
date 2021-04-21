# frozen_string_literal: true

module Types
  module Boards
    class BoardEpicInputType < BoardIssuableInputBaseType
      graphql_name 'EpicFilters'

      class NegatedEpicBoardIssueInputType < BoardIssuableInputBaseType
      end

      argument :not, NegatedEpicBoardIssueInputType,
               required: false,
               description: 'List of epic negated params.'

      argument :search, GraphQL::STRING_TYPE,
               required: false,
               description: 'Search query for epic title or description.'
    end
  end
end
