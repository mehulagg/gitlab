# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable GraphQL/AuthorizeTypes
    class BuildType < BaseObject
      graphql_name 'CiBuild'

      connection_type_class(Types::CountableConnectionType)

      # Only accessible through pipeline
      # authorize :read_pipeline

      field :id, ::Types::GlobalIDType[::Ci::Build], null: false,
            description: 'ID of the build'
      field :name, GraphQL::STRING_TYPE, null: false,
            description: 'Name of the build'
      field :stage, GraphQL::STRING_TYPE, null: false,
            description: 'Stage of the build'
      field :allow_failure, ::GraphQL::BOOLEAN_TYPE, null: false,
            description: 'Is this build allowed to fail'
      field :status, ::Types::Ci::BuildStatusEnum, null: false,
            description: "Status of the build"
      field :duration, GraphQL::INT_TYPE, null: true,
            description: 'Duration of the build in seconds'
      field :created_at, Types::TimeType, null: false,
            description: "Timestamp of the pipeline's creation"
      field :started_at, Types::TimeType, null: true,
            description: 'Timestamp when the pipeline was started'
      field :finished_at, Types::TimeType, null: true,
            description: "Timestamp of the pipeline's completion"
      field :trace, ::Types::Ci::TraceType, null: true,
            complexity: HIGH_COMPLEXITY,
            description: "Output of the build"
    end
    # rubocop: enable GraphQL/AuthorizeTypes
  end
end
