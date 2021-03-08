# frozen_string_literal: true

module Types
  module Boards
    class BoardEpicInputType < BoardIssueInputBaseType
    end

    class BoardEpicInputType < BoardIssueInputBaseType
      graphql_name 'BoardIssueInput'

      argument :not, NegatedBoardIssueInputType,
               required: false,
               description: 'List of negated params. Warning: this argument is experimental and a subject to change in future.'

      argument :search, GraphQL::STRING_TYPE,
               required: false,
               description: 'Search query for issue title or description.'
    end
  end
end
