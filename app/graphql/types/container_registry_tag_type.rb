# frozen_string_literal: true

module Types
  class ContainerRegistryTagType < BaseObject
    graphql_name 'ContainerRegistryTag'

    description 'A tag from a Container Repository'

    authorize :read_container_image

    field :name, GraphQL::STRING_TYPE, null: false, description: 'Name of the tag.'
    field :path, GraphQL::STRING_TYPE, null: false, description: 'Path of the tag.'
    field :location, GraphQL::STRING_TYPE, null: false, description: 'URL of the tag.'
    field :digest, GraphQL::STRING_TYPE, null: false, description: 'Digest of the tag.'
    field :revision, GraphQL::STRING_TYPE, null: false, description: 'Revision of the tag.'
    field :short_revision, GraphQL::STRING_TYPE, null: false, description: 'Short revision of the tag.'
    field :total_size, GraphQL::INT_TYPE, null: false, description: 'The size of the tag.'
    field :created_at, Types::TimeType, null: false, description: 'Timestamp when the container repository was created.'
  end
end
