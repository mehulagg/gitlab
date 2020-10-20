# frozen_string_literal: true

module Mutations
  module AlertManagement
    module HttpIntegration
      class HttpIntegrationBase < BaseMutation
        field :integration,
              Types::AlertManagement::HttpIntegrationType,
              null: true,
              description: "The updated HTTP integration"

        authorize :admin_operations

        private

        def find_object(id:)
          GitlabSchema.object_from_id(id, expected_class: ::AlertManagement::HttpIntegration)
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
