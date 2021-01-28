# frozen_string_literal: true

module Gitlab
  class UsageDataMetrics
    @metrics = []

    class << self
      def to_h
        metrics.inject({}) { |metric, hash| hash.merge(metric) }
      end

      def metrics
        load_metrics unless @metrics.present?

        @metrics
      end

      def load_metrics
        add_metric(key_path: 'uuid') { Gitlab::CurrentSettings.uuid }
        add_metric(key_path: 'counts.deployments') { Deployment.count }
      end

      def add_metric(key_path:, &block)
        @metrics << Gitlab::Usage::Metrics.instrument(key_path: key_path, &block)
      end
    end
  end
end
