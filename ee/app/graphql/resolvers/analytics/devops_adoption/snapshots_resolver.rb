# frozen_string_literal: true

module Resolvers
  module Analytics
    module DevopsAdoption
      class SnapshotsResolver < BaseResolver
        include Gitlab::Graphql::Authorize::AuthorizeResource
        include Gitlab::Allowable
        include LooksAhead

        type Types::Analytics::DevopsAdoption::SnapshotType.connection_type, null: true

        argument :end_time_before,
                 ::Types::TimeType,
                 required: false,
                 description: 'Filter by end time.'

        argument :end_time_after,
                 ::Types::TimeType,
                 required: false,
                 description: 'Filter by end time.'

        def resolve_with_lookahead(**args)
          authorize!(object)

          apply_lookahead(finder_class.new(current_user, object, params: args).execute)
        end

        private

        def finder_class
          ::Analytics::DevopsAdoption::SnapshotsFinder
        end

        def authorize!(enabled_namespace)
          authorized = if enabled_namespace.display_namespace
            can?(current_user, :view_group_devops_adoption, enabled_namespace.display_namespace)
          else
            can?(current_user, :view_instance_devops_adoption, :global)
          end

          raise_resource_not_available_error! unless authorized
        end
      end
    end
  end
end
