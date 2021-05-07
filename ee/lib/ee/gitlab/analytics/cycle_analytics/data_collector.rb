# frozen_string_literal: true

module EE
  module Gitlab
    module Analytics
      module CycleAnalytics
        module DataCollector
          # Deprecated, will be removed in the next milestone: https://gitlab.com/gitlab-org/gitlab/-/issues/328219
          def duration_chart_data
            strong_memoize(:duration_chart) do
              duration_chart.load
            end
          end

          def duration_chart_average_data
            strong_memoize(:duration_chart_average_data) do
              duration_chart.average_by_day
            end
          end

          private

          def duration_chart
            @duration_chart ||= ::Gitlab::Analytics::CycleAnalytics::DataForDurationChart.new(stage: stage, params: params, query: query)
          end
        end
      end
    end
  end
end
