# frozen_string_literal: true

module Gitlab
  class UsageDataMetrics
    class << self
      # Build the Usage Ping JSON payload from metrics YAML definitions
      def uncached_data
        Gitlab::Usage::MetricDefinition.definitions.map do |key_path, definition|
          instrumentation_class = definition.attributes[:instrumentation] || 'Gitlab::Usage::Metrics::Instrumentations::BaseMetric'

          instrumentation_class.constantize.new.usage_data
        end.reduce({}, :deep_merge)
      end
    end
  end
end
