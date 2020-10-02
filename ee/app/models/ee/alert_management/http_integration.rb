# frozen_string_literal: true

module EE
  module AlertManagement
    module HttpIntegration
      extend ::Gitlab::Utils::Override

      override :allows_multiple_integrations?
      def allows_multiple_integrations?
        project&.feature_available?(:multiple_alert_http_integrations)
      end
    end
  end
end
