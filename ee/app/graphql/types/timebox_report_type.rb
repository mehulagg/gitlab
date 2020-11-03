# frozen_string_literal: true
# rubocop: disable Graphql/AuthorizeTypes

module Types
  class TimeboxReportType < BaseObject
    graphql_name 'TimeboxReport'
    description 'Represents a fixed report about the timebox'

    field :stats, ::Types::TimeReportStatsType, null: true,
          description: ''
    field :burnup_time_series, [::Types::BurnupChartDailyTotalsType], null: true,
          description: 'Daily scope and completed totals for burnup charts'
  end
end
