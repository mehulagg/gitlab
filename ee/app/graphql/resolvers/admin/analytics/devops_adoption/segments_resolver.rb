# frozen_string_literal: true

module Resolvers
  module Admin
    module Analytics
      module DevopsAdoption
        class SegmentsResolver < BaseResolver
          include Gitlab::Graphql::Authorize::AuthorizeResource
          include Gitlab::Allowable

          type Types::Admin::Analytics::DevopsAdoption::SegmentType, null: true

          argument :display_namespace_id, ::Types::GlobalIDType[::Namespace],
                   required: false,
                   description: 'Filter by display namespace.'

          def resolve(display_namespace_id: nil, **)
            display_namespace_id = GlobalID.parse(display_namespace_id)
            display_namespace = Gitlab::Graphql::Lazy.force(GitlabSchema.find_by_gid(display_namespace_id))

            authorize!(display_namespace)

            ::Analytics::DevopsAdoption::SegmentsFinder.new(current_user, params: {
              display_namespace: display_namespace
            }).execute
          end

          private

          def authorize!(display_namespace)
            display_namespace ? authorize_with_namespace!(display_namespace) : authorize_global!
          end

          def authorize_global!
            unless can?(current_user, :view_instance_devops_adoption)
              raise_resource_not_available_error!
            end
          end

          def authorize_with_namespace!(display_namespace)
            unless can?(current_user, :view_group_devops_adoption, display_namespace)
              raise_resource_not_available_error!
            end
          end
        end
      end
    end
  end
end
