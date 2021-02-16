# frozen_string_literal: true

module Types
  module Boards
    module CommonFields
      include Types::BaseInterface

      field :name, type: GraphQL::STRING_TYPE, null: true,
            description: 'Name of the board.'

      field :web_path, GraphQL::STRING_TYPE, null: false,
            description: 'Web path of the board.'
      field :web_url, GraphQL::STRING_TYPE, null: false,
            description: 'Web URL of the board.'
    end
  end
end
