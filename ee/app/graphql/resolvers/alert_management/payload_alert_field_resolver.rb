# frozen_string_literal: true

module Resolvers
  module AlertManagement
    class PayloadAlertFieldResolver < BaseResolver
      argument :payload, GraphQL::STRING_TYPE,
               required: true,
               description: 'Sample payload for extracting alert fields for custom mappings.'

      type ::Types::AlertManagement::PayloadAlertFieldType, null: true

      alias_method :project, :object

      def resolve(payload:)
        params = { payload: payload }

        result = ::AlertManagement::ExtractAlertPayloadFieldsService
          .new(container: project, current_user: current_user, params: params)
          .execute

        raise GraphQL::ExecutionError, result.message if result.error?

        result.payload[:payload_alert_fields]
      end
    end
  end
end
