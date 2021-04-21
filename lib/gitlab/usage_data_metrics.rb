# frozen_string_literal: true

module Gitlab
  class UsageDataMetrics
    class << self
      # Build the Usage Ping JSON payload from metrics YAML definitions which have instrumentation class set
      def uncached_data
        ::Gitlab::Usage::MetricDefinition.all.map do |definition|
          instrumentation_class = definition.attributes[:instrumentation_class]

          if instrumentation_class.present?
            metric_value = instrumentation_class.constantize.new(time_constraints: time_constraints(definition)).value

            metric_payload(definition.key_path, metric_value)
          else
            {}
          end
        end.reduce({}, :deep_merge)
      end

      private

      def metric_payload(key_path, value)
        ::Gitlab::Usage::Metrics::KeyPathProcessor.unflatten_key_path(key_path, value)
      end

      def time_constraints(definition)
        ::Gitlab::Usage::Metrics::TimeConstraint.new(definition.attributes[:time_frame], definition.attributes[:data_source]).build
      end
    end
  end
end
