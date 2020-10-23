# frozen_string_literal: true

module Types
  class ContainerRepositoryDetailsType < BaseObject
    graphql_name 'ContainerRepositoryDetails'

    description 'A container repository details'

    authorize :read_container_image

    field :id, GraphQL::ID_TYPE, null: false, description: 'ID of the container repository.'
    field :name, GraphQL::STRING_TYPE, null: false, description: 'Name of the container repository.'
    field :path, GraphQL::STRING_TYPE, null: false, description: 'Path of the container repository.'
    field :can_delete, GraphQL::BOOLEAN_TYPE, null: false, description: 'Can the current user delete the container repository.'
    field :tags,
          Types::ContainerRegistryTagType.connection_type,
          null: true,
          description: 'Tags of the Container Repository'

    def can_delete
      Ability.allowed?(current_user, :update_container_image, object)
    end
  end
end
