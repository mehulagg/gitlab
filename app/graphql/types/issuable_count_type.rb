# frozen_string_literal: true

module Types
  class IssuableCountType < BaseObject
    graphql_name 'IssuableCount'


    field :opened, GraphQL::INT_TYPE, null: false,
      description: 'Total time reported as spent on the merge request'

    field :closed, GraphQL::INT_TYPE, null: false,
      description: 'Total time reported as spent on the merge request'

    field :all, GraphQL::INT_TYPE, null: false,
          description: 'Total time reported as spent on the merge request'
  end
end
