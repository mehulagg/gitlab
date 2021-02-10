# frozen_string_literal: true

class MetricsReportMetricEntity < Grape::Entity
  expose :name
  expose :value
  expose :previous_value, if: -> (metric, _) { metric.previous_value != metric.value }
end
