# frozen_string_literal: true

module Analytics
  module CycleAnalytics
    class DurationChartItemEntity < Grape::Entity
      expose :finished_at
      expose :duration_in_seconds
    end
  end
end
