# frozen_string_literal: true

module Types
  module Ci
    class JobArtifactType < BaseObject
      graphql_name 'CiJobArtifact'

      field :download_path, GraphQL::STRING_TYPE, null: true,
            description: "URL for downloading the artifact's file"

      def download_path
        ::Gitlab::Routing.url_helpers.download_project_job_artifacts_path(
          object.project,
          object.job,
          file_type: object.file_type
        )
      end
    end
  end
end
