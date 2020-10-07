# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    # Only accessible through builds
    class TraceSectionType < BaseObject
      graphql_name 'BuildSection'

      field :name, GraphQL::STRING_TYPE, null: true,
            description: 'Name of the section'
      field :byte_start, GraphQL::INT_TYPE, null: true,
            description: 'Start index of the section'
      field :byte_end, GraphQL::INT_TYPE, null: true,
            description: 'End index of the section'
      field :date_start, ::Types::TimeType, null: true,
            description: 'Time that the section started'
      field :date_end, ::Types::TimeType, null: true,
            description: 'Time that the section ended'
      field :content, ::GraphQL::STRING_TYPE, null: true,
            description: 'The content of this section'
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
