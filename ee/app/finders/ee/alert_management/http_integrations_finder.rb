# frozen_string_literal: true

module EE
  module AlertManagement
    module HttpIntegrationsFinder
      extend ::Gitlab::Utils::Override

      private

      override :by_availability
      def by_availability(collection)
        return collection if project.feature_available?(:multiple_alert_http_integrations)

        super
      end
    end
  end
end
