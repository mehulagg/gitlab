# frozen_string_literal: true

module EE
  module Mutations
    module AlertManagement
      module HttpIntegration
        module Create
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          prepended do
            argument :payload_example, ::Types::JsonStringType,
                     required: false,
                     description: 'The example of an alert payload.'

            argument :payload_attribute_mapping, ::Types::JsonStringType,
                     required: false,
                     description: 'The custom mapping of GitLab alert attributes to fields from the payload_example.'
          end

          private

          override :http_integration_params
          def http_integration_params(args)
            base_args = super(args)

            return base_args unless ::Gitlab::AlertManagement.custom_mapping_available?(project)

            args.slice(*base_args.keys, :payload_example, :payload_attribute_mapping)
          end
        end
      end
    end
  end
end
