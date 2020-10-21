# frozen_string_literal: true

module Mutations
  module AlertManagement
    module HttpIntegration
      class Destroy < HttpIntegrationBase
        graphql_name 'HttpIntegrationDestroy'

        argument :id, GraphQL::ID_TYPE,
                 required: true,
                 description: "The id of the integration to remove"

        def resolve(id:)
          integration = authorized_find!(id: id)

          response ::AlertManagement::HttpIntegrations::DestroyService.new(
            integration,
            current_user
          ).execute
        end
      end
    end
  end
end
