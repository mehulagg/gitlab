require 'prometheus/client'

module Gitlab
  module Metrics
    module Prometheus
      include Gitlab::CurrentSettings

      def metrics_folder_present?
        ENV.has_key?('prometheus_multiproc_dir') &&
          ::Dir.exist?(ENV['prometheus_multiproc_dir']) &&
          ::File.writable?(ENV['prometheus_multiproc_dir'])
      end

      def prometheus_metrics_enabled?
        return @prometheus_metrics_enabled if defined?(@prometheus_metrics_enabled)

        @prometheus_metrics_enabled = prometheus_metrics_enabled_unmemoized
      end

      def registry
        @registry ||= ::Prometheus::Client.registry
      end

      def counter(name, docstring, base_labels = {})
        provide_metric(name) || registry.counter(name, docstring, base_labels)
      end

      def summary(name, docstring, base_labels = {})
        provide_metric(name) || registry.summary(name, docstring, base_labels)
      end

      def gauge(name, docstring, base_labels = {})
        provide_metric(name) || registry.gauge(name, docstring, base_labels)
      end

      def histogram(name, docstring, base_labels = {}, buckets = ::Prometheus::Client::Histogram::DEFAULT_BUCKETS)
        provide_metric(name) || registry.histogram(name, docstring, base_labels, buckets)
      end

      def provide_metric(name)
        if prometheus_metrics_enabled?
          registry.get(name)
        else
          NullMetric.new
        end
      end

      private

      def prometheus_metrics_enabled_unmemoized
        metrics_folder_present? && current_application_settings[:prometheus_metrics_enabled] || false
      end
    end
  end
end
