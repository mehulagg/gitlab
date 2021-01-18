# frozen_string_literal: true

module EE
  module Mutations
    module AlertManagement
      module HttpIntegration
        module Update
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          prepended do
            argument :payload_example, ::Types::JsonStringType,
                     required: false,
                     description: 'The example of an alert payload.'

            argument :payload_attribute_mappings, [::Types::AlertManagement::PayloadAlertFieldInputType],
                     required: false,
                     description: 'The custom mapping of GitLab alert attributes to fields from the payload_example.'
          end

          private

          override :http_integration_params
          def http_integration_params(project, args)
            base_args = super(project, args)

            return base_args unless ::Gitlab::AlertManagement.custom_mapping_available?(project)

            validate_payload_example!(args[:payload_example])

            args.slice(*base_args.keys, :payload_example).merge(
              payload_attribute_mapping: payload_attribute_mapping(args[:payload_attribute_mappings])
            )
          end
        end
      end
    end
  end
end
