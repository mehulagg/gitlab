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

            ::Analytics::DevopsAdoption::Segment.all
          end

          private

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

