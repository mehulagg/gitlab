# frozen_string_literal: true

module Resolvers
  class ReleasesResolver < BaseResolver
    type Types::ReleaseType.connection_type, null: true

    argument :sort, Types::ReleaseSortEnum,
             required: false, default_value: :released_at_desc,
             description: 'Sort releases by this criteria'

    alias_method :project, :object

    # This resolver has a custom singular resolver
    def self.single
      Resolvers::ReleaseResolver
    end

    def resolve(sort:)
      return unless Feature.enabled?(:graphql_release_data, project, default_enabled: true)

      sort_to_params_map = {
        released_at_desc: { order_by: 'released_at', sort: 'desc' },
        released_at_asc: { order_by: 'released_at', sort: 'asc' },
        created_desc: { order_by: 'created_at', sort: 'desc' },
        created_asc: { order_by: 'created_at', sort: 'asc' }
      }

      ReleasesFinder.new(
        project,
        current_user,
        sort_to_params_map[sort]
      ).execute
    end
  end
end
