# frozen_string_literal: true

module Types
  module Ci
    class RunnerArchitectureType < BaseObject
      graphql_name 'RunnerArchitecture'

      authorize :assign_runner

      field :name, GraphQL::STRING_TYPE, null: false
      field :download_location, GraphQL::STRING_TYPE, null: false
      field :installation_instructions, GraphQL::STRING_TYPE, null: false
      field :register_instructions, GraphQL::STRING_TYPE, null: false
    end
  end
end
