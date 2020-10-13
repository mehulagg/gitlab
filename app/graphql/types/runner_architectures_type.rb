# frozen_string_literal: true

module Types
  class RunnerArchitectureType < BaseObject
    graphql_name 'RunnerArchitecture'

    authorize :read_project

    field :name
    field :download_location
    field :installation_instructions
    field :register_instructions
  end
end
