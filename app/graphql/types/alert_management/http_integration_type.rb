# frozen_string_literal: true

module Types
  module AlertManagement
    class HttpIntegrationType < BaseObject
      graphql_name 'AlertManagementHttpIntegration'
      description "Describes an endpoint and credentials used to accept alerts for a project"

      authorize :admin_operations

      field :id,
            GraphQL::ID_TYPE,
            null: false,
            description: 'ID of the alert'

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
    end
  end
end
