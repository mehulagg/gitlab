# frozen_string_literal: true

module Types
  module AlertManagement
    class HttpIntegrationType < BaseObject
      graphql_name 'AlertManagementHttpIntegration'
      description "Describes an endpoint and credentials used to accept alerts for a project"

      implements(Types::AlertManagement::IntegrationType)

      authorize :admin_operations

      def type
        'HTTP'
      end

      def api_url
        nil
      end
    end
  end
end
