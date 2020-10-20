# frozen_string_literal: true

module Mutations
  module AlertManagement
    module HttpIntegration
      class ResetToken < HttpIntegrationBase
        graphql_name 'HttpIntegrationResetToken'

        argument :id, GraphQL::ID_TYPE,
                 required: true,
                 description: "The id of the integration to mutate"

        def resolve(id:)
          integration = authorized_find!(id: id)
          integration.reset_token

          response integration
        end
      end
    end
  end
end
