# frozen_string_literal: true

module EE
  module AlertManagement
    module HttpIntegrationsFinder
      extend ::Gitlab::Utils::Override

      private

      override :multiple_alert_http_integrations?
      def multiple_alert_http_integrations?
        project.feature_available?(:multiple_alert_http_integrations)
      end
    end
  end
end
