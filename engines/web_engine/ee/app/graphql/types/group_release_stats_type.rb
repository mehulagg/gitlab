# frozen_string_literal: true

module Types
  class GroupReleaseStatsType < BaseObject
    graphql_name 'GroupReleaseStats'
    description 'Contains release-related statistics about a group'

    authorize :read_group_release_stats

    field :releases_count, GraphQL::INT_TYPE, null: true,
          description: 'Total number of releases in all descendant projects of the group. ' \
                       'Will always return `null` if `group_level_release_statistics` feature flag is disabled'

    def releases_count
      object.releases_count if Feature.enabled?(:group_level_release_statistics, object, default_enabled: true)
    end

    field :releases_percentage, GraphQL::INT_TYPE, null: true,
          description: "Percentage of the group's descendant projects that have at least one release. " \
                       'Will always return `null` if `group_level_release_statistics` feature flag is disabled'

    def releases_percentage
      object.releases_percentage if Feature.enabled?(:group_level_release_statistics, object, default_enabled: true)
    end
  end
end
