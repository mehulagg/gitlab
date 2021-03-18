# frozen_string_literal: true

module Types
  module Boards
    class BoardEpicInputType < BoardIssuableInputBaseType
      graphql_name 'EpicFilters'

      argument :not, BoardIssuableInputBaseType,
               required: false,
               description: 'List of negated params. Warning: this argument is experimental and a subject to change in future.'

      argument :search, GraphQL::STRING_TYPE,
               required: false,
               description: 'Search query for epic title or description.'
    end
  end
end
