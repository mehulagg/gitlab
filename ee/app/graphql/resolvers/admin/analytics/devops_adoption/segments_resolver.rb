# frozen_string_literal: true

module Resolvers
  module Admin
    module Analytics
      module DevopsAdoption
        class SegmentsResolver < BaseResolver
          include Gitlab::Graphql::Authorize::AuthorizeResource

          type Types::Admin::Analytics::DevopsAdoption::SegmentType, null: true

          def resolve
            authorize!

            if segments_feature_available?
              ::Analytics::DevopsAdoption::Segment.ordered_by_name
            else
              ::Analytics::DevopsAdoption::Segment.none
            end
          end

          private

          def segments_feature_available?
            License.feature_available?(:instance_level_devops_adoption)
          end

          def authorize!
            admin? || raise_resource_not_available_error!
          end

          def admin?
            context[:current_user].present? && context[:current_user].admin?
          end
        end
      end
    end
  end
end
