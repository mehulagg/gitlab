# frozen_string_literal: true

module Gitlab
  class UsageDataMetrics
    class << self
      # Build the Usage Ping JSON payload from metrics YAML definitions which have instrumentation class set
      def uncached_data
        Gitlab::Usage::MetricDefinition.all.map do |definition|
          instrumentation_class = definition.attributes[:instrumentation_class]
          if instrumentation_class.present?
            instrumentation_class.constantize.new.usage_data
          else
            {}
          end
        end.reduce({}, :deep_merge)
      end
    end
  end
end
