# frozen_string_literal: true

module Resolvers
  module AlertManagement
    class PersistedPayloadAlertFieldResolver < BaseResolver
      type ::Types::AlertManagement::PayloadAlertFieldType, null: true

      alias_method :integration, :object

      def resolve
        Gitlab::AlertManagement::AlertPayloadFieldExtractor
          .new(integration.project)
          .extract(integration.payload_example)
      end
    end
  end
end
