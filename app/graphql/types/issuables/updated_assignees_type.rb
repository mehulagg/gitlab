# frozen_string_literal: true
# rubocop:disable Graphql/AuthorizeTypes

module Types
  module Issuables
    class UpdatedAssigneesType < Types::BaseObject
      graphql_name 'UpdatedAssignees'
      description "Represents updated information about an issuable's assignees."

      field :assignees, [Types::UserType], null: true,
            description: 'Updated list of assignees of the issuable.'
    end
  end
end
