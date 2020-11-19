# frozen_string_literal: true

module Types
  module Ci
    class JobArtifactType < BaseObject
      graphql_name 'CiJobArtifact'

      field :download_path, GraphQL::STRING_TYPE, null: true,
            description: "URL for downloading the artifact's file",
            resolve: -> (_obj, _args, _ctx) { 'http://crimethinc.com' }
    end
  end
end
