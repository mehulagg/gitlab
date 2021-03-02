# frozen_string_literal: true

module Resolvers
  module Admin
    module Analytics
      module DevopsAdoption
        class SegmentsResolver < BaseResolver
          include Gitlab::Graphql::Authorize::AuthorizeResource

          type Types::Admin::Analytics::DevopsAdoption::SegmentType, null: true

          argument :parent_namespace_id, ::Types::GlobalIDType[::Namespace],
                   required: false,
                   description: 'Filter by ancestor namespace'

          argument :direct_descendants_only, ::GraphQL::BOOLEAN_TYPE,
                   required: false,
                   description: 'Limits segments to direct descendants of specified parent'

          def resolve(parent_namespace_id: nil, direct_descendants_only: false)
            parent = parent_namespace_id&.find

            authorize!(parent)

            ::Analytics::DevopsAdoption::SegmentsFinder.new(current_user, params: {
              parent_namespace: parent, direct_descendants_only: direct_descendants_only
            }).execute
          end

          private

          def segments_feature_available?(namespace = nil)
            if namespace
              License.feature_available?(:group_level_devops_adoption)
            else
              License.feature_available?(:instance_level_devops_adoption)
            end
          end

          def authorize!(parent)
            unless admin? && segments_feature_available?(parent)
              raise_resource_not_available_error!
            end
          end

          def admin?
            context[:current_user].present? && context[:current_user].admin?
          end
        end
      end
    end
  end
end
