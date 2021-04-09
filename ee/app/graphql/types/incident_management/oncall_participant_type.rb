# frozen_string_literal: true

module Types
  module IncidentManagement
    # rubocop: disable Graphql/AuthorizeTypes
    class OncallParticipantType < BaseObject
      graphql_name 'OncallParticipantType'
      description 'The rotation participant and color palette'

      field :id,
            Types::GlobalIDType[::IncidentManagement::OncallParticipant],
            null: true,
            description: 'ID of the on-call participant.'

      field :user, Types::UserType,
             null: true,
             description: 'The user who is participating.'

      field :color_palette, GraphQL::STRING_TYPE,
             null: true,
             description: 'The color palette to assign to the on-call user. For example "blue".'

      field :color_weight, GraphQL::STRING_TYPE,
             null: true,
             description: 'The color weight to assign to for the on-call user, for example "500". Max 4 chars. For easy identification of the user.'
     end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
