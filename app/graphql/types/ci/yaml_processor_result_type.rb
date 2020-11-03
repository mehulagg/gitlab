# frozen_string_literal: true

module Types
  module Ci
    class YamlProcessorResultType < BaseObject
      graphql_name 'YamlProcessorResult'

      field :stages, [Types::Ci::StageType], null: true,
            description: 'Stages in the config file'
      field :jobs, Types::Ci::JobType, null: true,
            description: 'Jobs in the config file'
    end
  end
end
