# frozen_string_literal: true

module EE
  module AlertManagement
    module HttpIntegrations
      module UpdateService
        extend ::Gitlab::Utils::Override

        private

        override :permitted_params_keys
        def permitted_params_keys
          return super unless ::Gitlab::AlertManagement.custom_mapping_available?(integration.project)

          super + %i[payload_example payload_attribute_mapping]
        end
      end
    end
  end
end
