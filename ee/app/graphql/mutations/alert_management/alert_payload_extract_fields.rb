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

        raise_resource_not_available_error! unless feature_enabled?(project)
        raise_resource_not_available_error! unless license_available?(project)

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

      def feature_enabled?(project)
        Feature.enabled?(:multiple_http_integrations_custom_mapping, project)
      end

      def license_available?(project)
        project.feature_available?(:multiple_alert_http_integrations)
      end
    end
  end
end
