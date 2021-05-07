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

        override :permitted_params_keys
        def permitted_params_keys
          return super unless ::Gitlab::AlertManagement.custom_mapping_available?(project)

          super + %i[payload_example payload_attribute_mapping]
        end
      end
    end
  end
end
