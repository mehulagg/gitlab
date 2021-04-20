# frozen_string_literal: true

module Types
  module Ci
    class RunnerType < BaseObject
      graphql_name 'CiRunner'
      authorize :read_runner

      field :id, GraphQL::ID_TYPE, null: false,
            description: 'ID of the runner.'
      field :name, GraphQL::STRING_TYPE, null: true,
            description: 'Name of the runner.'
      field :description, GraphQL::STRING_TYPE, null: true,
            description: 'Description of the runner.'
      field :contacted_at, Types::TimeType, null: true,
            description: 'Last contact from the runner.'
      field :active, GraphQL::BOOLEAN_TYPE, null: true,
            description: 'Indicates the runner is active.'
      field :version, GraphQL::STRING_TYPE, null: true,
            description: 'Version of the runner.'
      field :short_sha, GraphQL::STRING_TYPE, null: true,
            description: 'Short build  of the runner.'
      field :locked, GraphQL::BOOLEAN_TYPE, null: true,
            description: 'Indicates the runner is locked.'
      field :ip_address, GraphQL::STRING_TYPE, null: true,
            description: 'IP address of the runner.'
      field :runner_type, ::Types::Ci::RunnerTypeEnum, null: true,
            description: 'Type of the runner.'
    end
  end
end
