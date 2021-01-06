# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class TimeboxMetricsType < BaseObject
    graphql_name 'TimeboxMetrics'
    description 'Represents measured stats metrics for timeboxes'

    field :count, GraphQL::INT_TYPE, null: false,
          description: 'The count metric'

    field :weight, GraphQL::INT_TYPE, null: false,
          description: 'The weight metric'
  end
end
