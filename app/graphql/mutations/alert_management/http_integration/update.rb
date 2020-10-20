# frozen_string_literal: true

module Mutations
  module AlertManagement
    module HttpIntegration
      class Update < HttpIntegrationBase
        graphql_name 'HttpIntegrationUpdate'

        argument :id, GraphQL::ID_TYPE,
                 required: true,
                 description: "The id of the integration to mutate"

        argument :name, GraphQL::STRING_TYPE,
                 required: false,
                 description: "The name of the integration"

        argument :active, GraphQL::BOOLEAN_TYPE,
                 required: false,
                 description: "Whether the integration is receiving alerts"

        def resolve(args)
          integration = authorized_find!(id: args[:id])
          integration.update(args.slice(:name, :active))

          response integration
        end
      end
    end
  end
end
