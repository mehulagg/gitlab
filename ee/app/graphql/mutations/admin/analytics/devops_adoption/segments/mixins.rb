# frozen_string_literal: true

module Mutations
  module Admin
    module Analytics
      module DevopsAdoption
        module Segments
          module Mixins
            # This module ensures that the mutations are admin only
            module CommonMethods
              ADMIN_MESSAGE = 'You must be an admin to use this mutation'
              FEATURE_UNAVAILABLE_MESSAGE = 'Feature is not available'

              def ready?(**args)
                unless License.feature_available?(:instance_level_devops_adoption)
                  raise_resource_not_available_error!(FEATURE_UNAVAILABLE_MESSAGE)
                end

                super
              end

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
                raise_resource_not_available_error!(ADMIN_MESSAGE)
              end
            end
          end
        end
      end
    end
  end
end
