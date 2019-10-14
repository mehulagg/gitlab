# frozen_string_literal: true

module Projects
  module Alerting
    class NotifyService < BaseService
      include Gitlab::Utils::StrongMemoize

      def execute(token)
        return forbidden unless alerts_service_activated?
        return unauthorized unless valid_token?(token)

        process_incident_issues

        ServiceResponse.success
      rescue Gitlab::Alerting::NotificationPayloadParser::BadPayloadError
        bad_request
      end

      private

      delegate :alerts_service, to: :project

      def generic_alert_endpoint_enabled?
        Feature.enabled?(:generic_alert_endpoint, project)
      end

      def incident_management_available?
        project.feature_available?(:incident_management)
      end

      def alerts_service_activated?
        incident_management_available? &&
          generic_alert_endpoint_enabled? &&
          alerts_service.try(:active?)
      end

      def process_incident_issues
        IncidentManagement::ProcessAlertWorker
          .perform_async(project.id, parsed_payload)
      end

      def parsed_payload
        Gitlab::Alerting::NotificationPayloadParser.call(params.to_h)
      end

      def valid_token?(token)
        token == alerts_service.token
      end

      def bad_request
        ServiceResponse.error(message: 'Bad Request', http_status: 400)
      end

      def unauthorized
        ServiceResponse.error(message: 'Unauthorized', http_status: 401)
      end

      def forbidden
        ServiceResponse.error(message: 'Forbidden', http_status: 403)
      end
    end
  end
end
