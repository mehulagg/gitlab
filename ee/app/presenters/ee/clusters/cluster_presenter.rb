# frozen_string_literal: true

module EE
  module Clusters
    module ClusterPresenter
      extend ::Gitlab::Utils::Override

      override :health_data
      def health_data(clusterable)
        super.merge(
          'metrics-endpoint': clusterable.metrics_cluster_path(cluster, format: :json),
          'alerts-endpoint': alerts_endpoint,
          'prometheus-alerts-available': prometheus_alerts_available
        )
      end

      private

      def alerts_endpoint
        '/' if ::Feature.enabled?(:prometheus_computed_alerts)
      end

      def prometheus_alerts_available
        'true' if ::Feature.enabled?(:prometheus_computed_alerts)
      end
    end
  end
end
