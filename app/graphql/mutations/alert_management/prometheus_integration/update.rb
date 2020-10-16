# frozen_string_literal: true

module Mutations
  module AlertManagement
    module PrometheusIntegration
      class Update < IntegrationBase
        graphql_name 'PrometheusIntegrationUpdate'

        argument :active, GraphQL::BOOLEAN_TYPE,
                 required: false,
                 description: "Whether the integration is receiving alerts"

        argument :api_url, GraphQL::STRING_TYPE,
                 required: false,
                 description: "Endpoint at which prometheus can be queried"

        def resolve(args)
          integration = authorized_find!(full_path: args[:project_path])
          result = update_integration(project, args)

          response integration(project), result
        end
      end
    end
  end
end
