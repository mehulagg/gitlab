# frozen_string_literal: true

module Types
  module AlertManagement
    class PrometheusIntegrationType < BaseObject
      graphql_name 'AlertManagementPrometheusIntegration'
      description "Describes an endpoint and credentials used to accept Prometheus alerts for a project"

      implements(Types::AlertManagement::IntegrationType)

      authorize :admin_project

      alias_method :prometheus_service, :object

      def name
        prometheus_service.title
      end

      def type
        'PROMETHEUS'
      end

      def token
        prometheus_service.project&.alerting_setting&.token
      end

      def url
        ::Gitlab::Routing.url_helpers.notify_project_prometheus_alerts_url(prometheus_service.project, format: :json)
      end

      def active
        prometheus_service.manual_configuration?
      end
    end
  end
end
