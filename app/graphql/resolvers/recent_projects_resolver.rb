# frozen_string_literal: true

module Resolvers
  class RecentProjectsResolver < BaseResolver
    type Types::ProjectType, null: true

    argument :search, GraphQL::STRING_TYPE,
             required: false,
             description: 'Search query for project name, path, or description.'

    def resolve(**args)
      ::Gitlab::Search::RecentProjects.new(user: current_user).search(args[:search])
    end
  end
end
