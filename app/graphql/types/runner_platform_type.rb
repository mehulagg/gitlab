# frozen_string_literal: true

module Types
  class RunnerPlatformType < BaseObject
    graphql_name 'RunnerPlatform'

    authorize :read_project

    field :name
    field :human_readable_name
    field :architectures
  end
end
