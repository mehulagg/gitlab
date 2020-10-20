# frozen_string_literal: true

module Types
  module AlertManagement
    module IntegrationType
      include Types::BaseInterface
      graphql_name 'AlertManagementIntegration'

      field :id,
            GraphQL::ID_TYPE,
            null: true,
            description: 'ID of the integration'

      field :type,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'Type of integration'

      field :name,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'Name of the integration'

      field :active,
            GraphQL::BOOLEAN_TYPE,
            null: true,
            description: 'Whether the endpoint is currently accepting alerts'

      field :token,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'Token used to authenticate alert notification requests'

      field :url,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'Endpoint which accepts alert notifications'

      field :api_url,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'URL at which metrics can be queried'

      definition_methods do
        def resolve_type(object, context)
          if object.is_a?(::PrometheusService)
            Types::AlertManagement::PrometheusIntegrationType
          else
            Types::AlertManagement::HttpIntegrationType
          end
        end
      end

      orphan_types Types::AlertManagement::PrometheusIntegrationType,
                   Types::AlertManagement::HttpIntegrationType
    end
  end
end
