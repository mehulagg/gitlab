# frozen_string_literal: true

module Resolvers
  module Analytics
    module DevopsAdoption
      class SnapshotsResolver < BaseResolver
        include Gitlab::Allowable

        type Types::Analytics::DevopsAdoption::SnapshotType.connection_type, null: true

        argument :end_time_before,
                 ::Types::TimeType,
                 required: false,
                 description: 'Filter to snapshots with month end before the provided date.'

        argument :end_time_after,
                 ::Types::TimeType,
                 required: false,
                 description: 'Filter to snapshots with month end after the provided date.'

        def resolve(end_time_after: nil, end_time_before: nil)
          return [] unless authorize(object)

          params = {
            end_time_after: end_time_after,
            end_time_before: end_time_before,
            namespace_id: object.namespace_id
          }

          ::Analytics::DevopsAdoption::SnapshotsFinder.new(params: params).execute
        end

        private

        def authorize(enabled_namespace)
          if enabled_namespace.display_namespace
            can?(current_user, :view_group_devops_adoption, enabled_namespace.display_namespace)
          else
            can?(current_user, :view_instance_devops_adoption, :global)
          end
        end
      end
    end
  end
end
