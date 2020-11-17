# frozen_string_literal: true

module EE
  module Gitlab
    module Analytics
      module CycleAnalytics
        module DataCollector
          def duration_chart_data
            strong_memoize(:duration_chart) do
              ::Gitlab::Analytics::CycleAnalytics::DataForDurationChart.new(stage: stage, params: params, query: query).load
            end
          end
        end
      end
    end
  end
end
