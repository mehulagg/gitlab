# frozen_string_literal: true

module Analytics
  module CycleAnalytics
    class DurationChartAverageItemEntity < Grape::Entity
      expose :date
      expose :average_duration_in_seconds
    end
  end
end
