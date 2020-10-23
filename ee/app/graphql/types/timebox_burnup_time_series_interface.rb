# frozen_string_literal: true

module Types
  module TimeboxBurnupTimeSeriesInterface
    include BaseInterface

    field :burnup_time_series, [::Types::BurnupChartDailyTotalsType], null: true,
          resolver: ::Resolvers::TimeboxBurnupTimeSeriesResolver,
          description: 'Daily scope and completed totals for burnup charts',
          complexity: 175
  end
end
