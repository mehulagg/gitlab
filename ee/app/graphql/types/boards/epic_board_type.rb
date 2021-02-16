# frozen_string_literal: true

module Types
  module Boards
    class EpicBoardType < BaseObject
      # implements ::Types::Boards::CommonFields

      graphql_name 'EpicBoard'
      description 'Represents an epic board'

      accepts ::Boards::EpicBoard
      authorize :read_epic_board

      present_using EpicBoardPresenter

      field :id, type: ::Types::GlobalIDType[::Boards::EpicBoard], null: false,
            description: 'Global ID of the board.'

      field :lists,
            Types::Boards::EpicListType.connection_type,
            null: true,
            description: 'Epic board lists.',
            extras: [:lookahead],
            resolver: Resolvers::Boards::EpicListsResolver



      field :name, type: GraphQL::STRING_TYPE, null: true,
            description: 'Name of the board.'

      field :web_path, GraphQL::STRING_TYPE, null: false,
            description: 'Web path of the board.'
      field :web_url, GraphQL::STRING_TYPE, null: false,
            description: 'Web URL of the board.'
    end
  end
end
