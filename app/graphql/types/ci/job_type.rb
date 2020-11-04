# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    class JobType < BaseObject
      graphql_name 'CiJob'

      field :name, GraphQL::STRING_TYPE, null: true,
        description: 'Name of the job'
      field :needs, JobType.connection_type, null: true,
        description: 'Builds that must complete before the jobs run'
      field :detailed_status, Types::Ci::DetailedStatusType, null: true,
            description: 'Detailed status of the job',
            resolve: -> (obj, _args, ctx) { obj.detailed_status(ctx[:current_user]) }
      field :scheduled_at, Types::TimeType, null: true,
        description: 'Schedule for the build'

      field :artifacts, Types::Ci::JobArtifactType.connection_type, null: true,
            description: 'Artifacts produced by the job',
            method: :job_artifacts
    end
  end
end
