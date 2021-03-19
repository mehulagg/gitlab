# frozen_string_literal: true

module Types
  class GroupStatsType < BaseObject
    graphql_name 'GroupStats'
    description 'Contains statistics about a group'

    authorize :read_group

    field :release_stats, Types::GroupReleaseStatsType,
          null: true, method: :itself,
          description: 'Statistics related to releases within the group.'
  end
end
