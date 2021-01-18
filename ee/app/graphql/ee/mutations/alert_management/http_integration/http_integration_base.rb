# frozen_string_literal: true

module EE
  module Mutations
    module AlertManagement
      module HttpIntegration
        module HttpIntegrationBase
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          private

          def payload_attribute_mapping(mappings)
            Array(mappings).each_with_object({}) do |m, h|
              h[m.field_name] = { path: m.path, type: m.type, label: m.label }
            end
          end

          def validate_payload_example!(payload_example)
            return if ::Gitlab::Utils::DeepSize.new(payload_example).valid?

            raise ::Gitlab::Graphql::Errors::ArgumentError, 'payloadExample JSON is too big'
          end
        end
      end
    end
  end
end
