# frozen_string_literal: true

module Mutations
  module AlertManagement
    module HttpIntegration
      class ResetToken < IntegrationBase
        graphql_name 'HttpIntegrationResetToken'

        argument :id, GraphQL::ID_TYPE,
                 required: true,
                 description: "The id of the integration to mutate"

        def resolve(args)
          integration = authorized_find!(project_path: args[:project_path], id: args[:id])

          integration.update!(token: nil)

          response integration
        end
      end
    end
  end
end
