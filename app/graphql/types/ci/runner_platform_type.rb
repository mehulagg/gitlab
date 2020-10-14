# frozen_string_literal: true

module Types
  module Ci
    class RunnerPlatformType < BaseObject
      graphql_name 'RunnerPlatform'

      authorize :assign_runner

      field :name, GraphQL::STRING_TYPE, null: false
      field :human_readable_name, GraphQL::STRING_TYPE, null: false
      field :architectures, Types::Ci::RunnerArchitectureType, null: false
    end
  end
end
