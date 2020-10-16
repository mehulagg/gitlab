# frozen_string_literal: true

module Mutations
  module AlertManagement
    module PrometheusIntegration
      class IntegrationBase < BaseMutation
        include ResolvesProject

        argument :project_path, GraphQL::ID_TYPE,
                 required: true,
                 description: "The project the integration to mutate is in"

        field :integration,
              Types::AlertManagement::PrometheusIntegrationType,
              null: true,
              description: "The newly created integration"

        authorize :admin_project

        private

        def find_object(full_path:)
          resolve_project(full_path: full_path)
        end

        def integration(project)
          project.find_or_initialize_service(::PrometheusService.to_param)
        end

        def update_integration(project, args)
          ::Projects::Operations::UpdateService.new(
            project,
            current_user,
            {
              prometheus_integration_attributes: {
                manual_configuration: args[:active],
                api_url: args[:api_url]
              }.compact
            }
          ).execute
        end

        def response(integration, result)
          {
            integration: integration,
            errors: Array(result[:message])
          }
        end
      end
    end
  end
end
