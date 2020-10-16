# frozen_string_literal: true

module Mutations
  module AlertManagement
    module PrometheusIntegration
      class Create < IntegrationBase
        graphql_name 'PrometheusIntegrationCreate'

        argument :active, GraphQL::BOOLEAN_TYPE,
                 required: false,
                 description: "Whether the integration is receiving alerts",
                 default_value: false

        argument :api_url, GraphQL::STRING_TYPE,
                 required: true,
                 description: "Endpoint at which prometheus can be queried"

        def resolve(args)
          project = authorized_find!(full_path: args[:project_path])
          result = update_integration(project, args)

          response integration(project), result
        end
      end
    end
  end
end
