# frozen_string_literal: true

module Resolvers
  module Admin
    module Analytics
      module DevopsAdoption
        class SegmentsResolver < BaseResolver
          include Gitlab::Graphql::Authorize::AuthorizeResource
          include Gitlab::Allowable

          type Types::Admin::Analytics::DevopsAdoption::SegmentType, null: true

          argument :parent_namespace_id, ::Types::GlobalIDType[::Namespace],
                   required: false,
                   description: 'Filter by ancestor namespace.'

          argument :direct_descendants_only, ::GraphQL::BOOLEAN_TYPE,
                   required: false,
                   description: 'Limits segments to direct descendants of specified parent.'

          def resolve(parent_namespace_id: nil, direct_descendants_only: false, **)
            parent = GlobalID::Locator.locate(parent_namespace_id) if parent_namespace_id

            authorize!(parent)

            ::Analytics::DevopsAdoption::SegmentsFinder.new(current_user, params: {
              parent_namespace: parent, direct_descendants_only: direct_descendants_only
            }).execute
          end

          private

          def authorize!(parent)
            parent ? authorize_with_namespace!(parent) : authorize_global!
          end

          def authorize_global!
            unless can?(current_user, :view_instance_devops_adoption)
              raise_resource_not_available_error!
            end
          end

          def authorize_with_namespace!(parent)
            unless can?(current_user, :view_group_devops_adoption, parent)
              raise_resource_not_available_error!
            end
          end
        end
      end
    end
  end
end
