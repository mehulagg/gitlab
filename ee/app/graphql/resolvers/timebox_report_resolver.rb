# frozen_string_literal: true

module Resolvers
  class TimeboxReportResolver < BaseResolver
    type Types::TimeboxReportType, null: true

    alias_method :timebox, :synchronized_object

    def resolve(*args)
      return {} unless timebox.burnup_charts_available?

      response = TimeboxReportService.new(timebox).execute

      raise GraphQL::ExecutionError, response.message if response.error?

      payload = response.payload
      {
        stats: build_stats(payload[:burnup_time_series]&.last)
      }.merge(payload)
    end

    private

    def build_stats(data)
      return unless data

      {
        complete: {
          count: data[:completed_count],
          weight: data[:completed_weight]
        },
        incomplete: {
          count: data[:scope_count] - data[:completed_count],
          weight: data[:scope_weight] - data[:completed_weight]
        },
        total: {
          count: data[:scope_count],
          weight: data[:scope_weight]
        }
      }
    end
  end
end
