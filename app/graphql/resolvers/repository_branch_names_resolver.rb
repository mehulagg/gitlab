# frozen_string_literal: true

module Resolvers
  class RepositoryBranchNamesResolver < BaseResolver
    type ::GraphQL::STRING_TYPE, null: false

    calls_gitaly!

    argument :search_pattern, GraphQL::STRING_TYPE,
      required: true,
      description: 'The pattern to search for branch names by.'

    argument :offset, GraphQL::INT_TYPE,
      required: true,
      description: 'The number of branch names to skip.'

    argument :limit, GraphQL::INT_TYPE,
      required: true,
      description: 'The number of branch names to return.'

    def resolve(search_pattern:, offset:, limit:)
      names = branch_names(search_pattern)
      return unless names

      names.lazy.drop(offset).take(limit) # rubocop:disable CodeReuse/ActiveRecord
    end

    private

    def branch_names(search_pattern)
      Repositories::BranchNamesFinder.new(object, search: search_pattern).execute
    end
  end
end
