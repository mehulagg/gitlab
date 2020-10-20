# frozen_string_literal: true

module Mutations
  module AlertManagement
    module HttpIntegration
      class Destroy < HttpIntegrationBase
        graphql_name 'HttpIntegrationDestroy'

        argument :id, GraphQL::ID_TYPE,
                 required: true,
                 description: "The id of the integration to delete"

        def resolve(id:)
          integration = authorized_find!(id: id)
          integration.destroy

          response integration
        end
      end
    end
  end
end
