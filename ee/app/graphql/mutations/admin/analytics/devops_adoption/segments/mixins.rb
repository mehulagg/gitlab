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
                  raise ::Gitlab::Graphql::Errors::ResourceNotAvailable, FEATURE_UNAVAILABLE_MESSAGE
                end

                unless current_user&.admin?
                  raise Gitlab::Graphql::Errors::ResourceNotAvailable, ADMIN_MESSAGE
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
            end
          end
        end
      end
    end
  end
end
