# frozen_string_literal: true

module Types
  class ContainerRepositoryType < BaseObject
    graphql_name 'ContainerRepository'

    description 'A container repository'

    authorize :read_container_image

    field :id, GraphQL::ID_TYPE, null: false, description: 'ID of the container repository'
    field :name, GraphQL::STRING_TYPE, null: false, description: 'Name of the container repository'
    field :path, GraphQL::STRING_TYPE, null: false, description: 'Path of the container repository'
    field :location, GraphQL::STRING_TYPE, null: false, description: 'Url of the container repository'
    field :created_at, Types::TimeType, null: false, description: 'Timestamp of when the container repository was created'
    field :updated_at, Types::TimeType, null: false, description: 'Timestamp of when the container repository was updated'
    field :status, Types::ContainerRepositoryStatusEnum, null: true, description: 'Status of the container repository'
    field :tags_count, GraphQL::INT_TYPE, null: false, description: 'Number of tags associated with this image'
  end
end
