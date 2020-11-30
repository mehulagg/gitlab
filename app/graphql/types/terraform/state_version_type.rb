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

      field :job, Types::Ci::JobType,
            null: true,
            authorize: :read_build,
            description: 'The job that created this version',
            resolve: -> (version, _, _) { Gitlab::Graphql::Loaders::BatchModelLoader.new(::Ci::Build, version.ci_build_id).find }

      field :created_at, Types::TimeType,
            null: false,
            description: 'Timestamp the version was created'

      field :updated_at, Types::TimeType,
            null: false,
            description: 'Timestamp the version was updated'

      field :download_path, GraphQL::STRING_TYPE,
            null: true,
            description: "URL for downloading the version's JSON file"

      field :serial, GraphQL::INT_TYPE,
            null: true,
            description: 'Serial number of the version'

      def download_path
        "/api/#{::API::API.version}/projects/#{object.project_id}/terraform/state/#{object.terraform_state.name}/versions/#{object.version}"
      end

      def serial
        object.version
      end
    end
  end
end
