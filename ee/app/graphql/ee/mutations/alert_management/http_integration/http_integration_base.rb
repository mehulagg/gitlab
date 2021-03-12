# frozen_string_literal: true

module EE
  module Mutations
    module AlertManagement
      module HttpIntegration
        module HttpIntegrationBase
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          private

          def validate_payload_example!(payload_example)
            return if ::Gitlab::Utils::DeepSize.new(payload_example).valid?

            raise ::Gitlab::Graphql::Errors::ArgumentError, 'payloadExample JSON is too big'
          end

          override :http_integration_params
          def http_integration_params(project, args)
            base_args = super(project, args)

            return base_args unless ::Gitlab::AlertManagement.custom_mapping_available?(project)

            validate_payload_example!(args[:payload_example])

            args
              .slice(*base_args.keys, :payload_example)
              .merge(payload_attribute_mapping_params(args))
          end

          def payload_attribute_mapping_params(args)
            # Don't process payload_attribute_mapping when it's not part of a mutation params.
            # Otherwise, it's going to reset already persisted value.
            return {} unless args.key?(:payload_attribute_mappings)

            { payload_attribute_mapping: payload_attribute_mapping(args[:payload_attribute_mappings]) }
          end

          def payload_attribute_mapping(mappings)
            Array(mappings).each_with_object({}) do |m, h|
              h[m.field_name] = { path: m.path, type: m.type, label: m.label }
            end
          end
        end
      end
    end
  end
end
