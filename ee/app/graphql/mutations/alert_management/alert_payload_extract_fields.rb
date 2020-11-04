# frozen_string_literal: true

module Mutations
  module AlertManagement
    class AlertPayloadExtractFields < BaseMutation
      include ResolvesProject

      graphql_name 'AlertPayloadExtractFields'

      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project'

      argument :payload, GraphQL::Types::JSON, # rubocop:disable Graphql/JSONType
               required: true,
               description: 'The alert JSON payload to be parsed'

      field :payload_alert_fields,
            [::Types::AlertManagement::PayloadAlertFieldType],
            null: true,
            description: 'List of parsed payload fields'

      authorize :admin_operations

      def resolve(args)
        project = authorized_find!(full_path: args[:project_path])

        {
          payload_alert_fields: [
            ::AlertManagement::AlertPayloadField.new(
              project: project,
              path: 'foo.bar',
              label: 'Bar',
              type: 'string'
            )
          ]
        }
      end

      private

      def find_object(full_path:)
        resolve_project(full_path: full_path)
      end
    end
  end
end
