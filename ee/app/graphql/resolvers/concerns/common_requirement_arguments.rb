# frozen_string_literal: true

module CommonRequirementArguments
  extend ActiveSupport::Concern

  included do
    argument :sort, Types::SortEnum,
              required: false,
              description: 'List requirements by sort order.'

    argument :state, Types::RequirementsManagement::RequirementStateEnum,
              required: false,
              description: 'Filter requirements by state.'

    argument :search, GraphQL::STRING_TYPE,
              required: false,
              description: 'Search query for requirement title.'

    argument :author_username, [GraphQL::STRING_TYPE],
              required: false,
              description: 'Filter requirements by author username.'
  end
end
