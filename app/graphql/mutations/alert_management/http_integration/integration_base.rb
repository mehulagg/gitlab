# frozen_string_literal: true

module Mutations
  module AlertManagement
    module HttpIntegration
      class IntegrationBase < BaseMutation
        include ResolvesProject

        argument :project_path, GraphQL::ID_TYPE,
                 required: true,
                 description: "The project the integration to mutate is in"

        field :integration,
              Types::AlertManagement::HttpIntegrationType,
              null: true,
              description: "The newly created integration"

        authorize :admin_operations

        private

        def find_object(project_path:, id:)
          project = resolve_project(full_path: project_path)

          return unless project

          resolver = Resolvers::AlertManagement::IntegrationResolver.single.new(object: project, context: context, field: nil)
          resolver.resolve(id: id, type: 'HTTP')
        end

        def response(integration)
          {
            integration: integration,
            errors: integration.errors.full_messages
          }
        end
      end
    end
  end
end
