# frozen_string_literal: true

module Types
  module Ci
    class JobArtifactType < BaseObject
      graphql_name 'CiJobArtifact'

      field :id, GraphQL::ID_TYPE, null: false,
            description: 'ID of the artifact'
    end
  end
end
