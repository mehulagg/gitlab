# frozen_string_literal: true

module Types
  module IncidentManagement
    # rubocop: disable Graphql/AuthorizeTypes
    class OncallUserInputType < BaseInputObject
      graphql_name 'OncallUserInputType'
      description 'The rotation user and color palette'

      argument :username, GraphQL::STRING_TYPE,
                required: true,
                description: 'The username of the user to participate in the on-call rotation. i.e user_one'

      argument :color_palette, GraphQL::STRING_TYPE,
                required: false,
                description: 'The color palette to assign to the on-call user, for example: "blue".'

      argument :color_weight, GraphQL::STRING_TYPE,
                required: false,
                description: 'The color weight to assign to for the on-call user, for example "500". Max 4 chars. For easy identification of the user.'
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
