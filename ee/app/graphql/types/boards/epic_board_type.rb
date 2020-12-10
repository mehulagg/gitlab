# frozen_string_literal: true

module Types
  module Boards
    class EpicBoardType < BaseObject
      graphql_name 'EpicBoard'
      description 'Represents an epic board'

      accepts ::Boards::EpicBoard
      authorize :read_epic_board

      field :id, type: ::Types::GlobalIDType[::Boards::EpicBoard], null: false,
            description: 'Global ID of the board'

      field :name, type: GraphQL::STRING_TYPE, null: true,
            description: 'Name of the board'

      field :epic_lists,
            Types::Boards::EpicListType.connection_type,
            null: true,
            description: 'Epic board lists',
            resolver: Resolvers::Boards::EpicListsResolver
    end
  end
end
