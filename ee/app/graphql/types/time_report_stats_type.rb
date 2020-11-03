# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class TimeReportStatsType < BaseObject
    graphql_name 'TimeReportStats'
    description 'Represents the time report totals for a given timebox'

    field :complete, ::Types::TimeboxMetricsType, null: true,
          description: 'Completed issues metrics'

    field :incomplete, ::Types::TimeboxMetricsType, null: true,
          description: 'Incompleted issues metrics'

    field :total, ::Types::TimeboxMetricsType, null: true,
          description: 'Total issues metrics'
  end
end
