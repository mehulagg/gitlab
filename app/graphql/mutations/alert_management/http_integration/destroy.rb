# frozen_string_literal: true

module Mutations
  module AlertManagement
    module HttpIntegration
      class Destroy < IntegrationBase
        graphql_name 'HttpIntegrationDestroy'

        argument :id, GraphQL::ID_TYPE,
                 required: true,
                 description: "The id of the integration to mutate"

        def resolve(args)
          integration = authorized_find!(project_path: args[:project_path], id: args[:id])

          integration.destroy!

          response integration
        end
      end
    end
  end
end
