# frozen_string_literal: true

module Types
  class SavedReplyType < BaseObject
    graphql_name 'SavedReply'

    field :id, GraphQL::ID_TYPE, null: false,
          description: 'ID of the note template'
    field :title, GraphQL::ID_TYPE, null: false,
          description: 'Title of the note template'
    field :note, GraphQL::ID_TYPE, null: false,
          description: 'Full note text of the note template'
  end
end
