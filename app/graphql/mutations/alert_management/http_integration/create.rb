# frozen_string_literal: true

module Mutations
  module AlertManagement
    module HttpIntegration
      class Create < IntegrationBase
        graphql_name 'HttpIntegrationCreate'

        argument :name, GraphQL::STRING_TYPE,
                 required: true,
                 description: "The name of the integration"

        argument :active, GraphQL::BOOLEAN_TYPE,
                 required: false,
                 description: "Whether the integration is receiving alerts"

        def resolve(args)
          project = authorized_find!(full_path: args[:project_path])

          integration = ::AlertManagement::HttpIntegration.create!(
            project: project,
            **args.slice(:name, :active)
          )

          response integration
        end

        private

        def find_object(full_path:)
          resolve_project(full_path: full_path)
        end
      end
    end
  end
end
