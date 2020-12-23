# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    class DeploymentFrequencyValueType < BaseObject
      graphql_name 'DeploymentFrequencyValue'

      field :from, Types::TimeType, null: true,
            description: 'Start time of this data point, inclusive.'
      field :to, Types::TimeType, null: true,
            description: 'End time of this data point, exclusive.'
      field :value, GraphQL::INT_TYPE, null: true,
            description: 'Number of deployments during the time period.'
    end
  end
end
