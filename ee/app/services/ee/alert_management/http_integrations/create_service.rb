# frozen_string_literal: true

module EE
  module AlertManagement
    module HttpIntegrations
      module CreateService
        extend ::Gitlab::Utils::Override

        private

        override :creation_allowed?
        def creation_allowed?
          project.feature_available?(:multiple_alert_http_integrations) || super
        end
      end
    end
  end
end
