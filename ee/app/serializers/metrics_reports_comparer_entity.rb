# frozen_string_literal: true

class MetricsReportsComparerEntity < Grape::Entity
  expose :new_metrics, using: MetricsReportMetricEntity
  expose :existing_metrics, using: MetricsReportMetricEntity
  expose :removed_metrics, using: MetricsReportMetricEntity
end
