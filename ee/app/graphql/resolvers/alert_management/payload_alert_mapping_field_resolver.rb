# frozen_string_literal: true

module Resolvers
  module AlertManagement
    class PayloadAlertMappingFieldResolver < BaseResolver
      type ::Types::AlertManagement::PayloadAlertMappingFieldType, null: true

      alias_method :integration, :object

      def resolve
        integration.payload_attribute_mapping.map do |field_name, mapping|
          ::AlertManagement::AlertPayloadField.new(
            project: integration.project,
            field_name: field_name,
            path: mapping['path'],
            label: mapping['label'],
            type: mapping['type']
          )
        end
      end
    end
  end
end
