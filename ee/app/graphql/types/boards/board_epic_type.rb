# frozen_string_literal: true

module Types
  module Boards
    # rubocop: disable Graphql/AuthorizeTypes
    class BoardEpicType < EpicType
      graphql_name 'BoardEpic'
      description 'Represents an epic on an issue board'

      field :user_preferences, Types::Boards::EpicUserPreferencesType, null: true,
            description: 'User preferences for the epic on the issue board',
            resolver: Resolvers::Boards::EpicUserPreferencesResolver
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
