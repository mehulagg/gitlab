# frozen_string_literal: true

module Gitlab
  module Usage
    class Metrics
      class << self
        def paths
          @paths ||= [Rails.root.join('config', 'metrics', '**', '*.yml')]
        end

        def definitions
          @definitions ||= metrics.transform_values { |metric| metric.definition }
        end

        def metrics
          @metrics ||= load_all!
        end

        def instrument(key_path:, &block)
          raise "Metric #{key_path} undefined" unless metrics[key_path].present?

          metrics[key_path].instrument(&block)
        end

        private

        def load_all!
          paths.each_with_object({}) do |glob_path, definitions|
            load_all_from_path!(definitions, glob_path)
          end
        end

        def load_all_from_path!(metrics, glob_path)
          Dir.glob(glob_path).each do |path|
            metric = load_from_file(path)

            if previous = metrics[metric.key_path]
              Gitlab::ErrorTracking.track_and_raise_for_dev_exception(Metric::InvalidMetricError.new("Metric '#{metric.key_path}' is already defined in '#{previous.definition.key_path}'"))
            end

            metrics[metric.key_path] = metric
          end
        end

        def load_from_file(path)
          definition = File.read(path)
          definition = YAML.safe_load(definition)
          definition.deep_symbolize_keys!

          definition = Gitlab::Usage::MetricDefinition.new(path, definition).tap(&:validate!)

          Gitlab::Usage::Metric.new(definition: definition)
        rescue => e
          Gitlab::ErrorTracking.track_and_raise_for_dev_exception(Metric::InvalidMetricError.new(e.message))
        end
      end
    end
  end
end

Gitlab::Usage::MetricDefinition.prepend_if_ee('EE::Gitlab::Usage::Metrics')
