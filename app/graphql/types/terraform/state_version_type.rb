# frozen_string_literal: true

module Types
  module Terraform
    class StateVersionType < BaseObject
      graphql_name 'TerraformStateVersion'

      authorize :read_terraform_state

      field :id, GraphQL::ID_TYPE,
            null: false,
            description: 'ID of the Terraform state version'

      field :created_by_user, Types::UserType,
            null: true,
            authorize: :read_user,
            description: 'The user that created this version',
            resolve: -> (version, _, _) { Gitlab::Graphql::Loaders::BatchModelLoader.new(User, version.created_by_user_id).find }

      field :file, GraphQL::Types::JSON, # rubocop:disable Graphql/JSONType
            method: :content,
            null: false,
            description: 'The contents of the Terraform state file for this version'

      field :created_at, Types::TimeType,
            null: false,
            description: 'Timestamp the version was created'

      field :updated_at, Types::TimeType,
            null: false,
            description: 'Timestamp the version was updated'
    end
  end
end
