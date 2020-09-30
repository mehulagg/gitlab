# frozen_string_literal: true

module Types
  module RequirementsManagement
    # rubocop: disable Graphql/AuthorizeTypes
    class RequirementStatesCountType < BaseObject
      graphql_name 'RequirementStatesCount'
      description 'Counts of requirements by their state'

      field :opened, GraphQL::INT_TYPE, null: true, description: 'Number of opened requirements'
      field :archived, GraphQL::INT_TYPE, null: true, description: 'Number of archived requirements'
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
