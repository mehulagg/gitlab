# frozen_string_literal: true

module Types
  module TimeboxReportInterface
    include BaseInterface

    field :report, Types::TimeboxReportType, null: true,
          resolver: ::Resolvers::TimeboxReportResolver,
          description: 'Historically accurate report about the timebox',
          complexity: 175

    field :burnup_time_series, [::Types::BurnupChartDailyTotalsType], null: true,
          resolver: ::Resolvers::TimeboxBurnupTimeSeriesResolver,
          description: 'Daily scope and completed totals for burnup charts',
          complexity: 175
  end
end
