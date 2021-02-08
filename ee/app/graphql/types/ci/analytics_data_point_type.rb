module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    class AnalyticsDataPointType < BaseObject
      graphql_name 'AnalyticsDataPoint'

      field :value, GraphQL::INT_TYPE, null: true,
            description: 'The value of this data point'
      field :from, ::Types::TimeType, null: true,
            description: 'The beginning of this data point\'s date range (inclusive)'
      field :to, ::Types::TimeType, null: true,
            description: 'The end of this data point\'s date range (exclusive)'
    end
  end
end
