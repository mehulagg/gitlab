# frozen_string_literal: true

module Mutations
  module Analytics
    module DevopsAdoption
      module Segments
        module Mixins
          module CommonMethods
            private

            def resolve_segment(response)
              segment = response.payload.fetch(:segment)

              {
                segment: response.success? ? response.payload.fetch(:segment) : nil,
                errors: errors_on_object(segment)
              }
            end

            def with_authorization_handler
              yield
            rescue ::Analytics::DevopsAdoption::Segments::AuthorizationError => e
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
