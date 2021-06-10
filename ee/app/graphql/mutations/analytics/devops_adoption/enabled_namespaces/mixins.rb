# frozen_string_literal: true

module Mutations
  module Analytics
    module DevopsAdoption
      module EnabledNamespaces
        module Mixins
          module CommonMethods
            private

            def resolve_enabled_namespace(response)
              enabled_namespace = response.payload.fetch(:enabled_namespace)

              {
                enabled_namespace: response.success? ? enabled_namespace : nil,
                errors: errors_on_object(enabled_namespace)
              }
            end

            def with_authorization_handler
              yield
            rescue ::Analytics::DevopsAdoption::EnabledNamespaces::AuthorizationError => e
              handle_unauthorized!(e)
            end

            def handle_unauthorized!(_exception)
              raise_resource_not_available_error!
            end
          end
        end
      end
    end
  end
end
