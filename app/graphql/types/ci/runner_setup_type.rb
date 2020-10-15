# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    class RunnerSetup < BaseObject
      graphql_name 'RunnerSetup'

      field :install_instructions, GraphQL::STRING_TYPE, null: false,
        description: 'Instructions for installing gitlab-runner on the specified architecture'
      field :register_instructions, GraphQL::STRING_TYPE, null: false,
        description: 'Instructions for registering gitlab-runner'
    end
  end
end
