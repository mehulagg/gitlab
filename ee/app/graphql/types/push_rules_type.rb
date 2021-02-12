# frozen_string_literal: true

module Types
  class PushRulesType < BaseObject
    graphql_name 'PushRules'
    description 'Represents rules that commit pushes must follow'
    accepts ::PushRule

    authorize :read_project

    field :reject_unsigned_commits,
      GraphQL::BOOLEAN_TYPE,
      null: false,
      description: 'Only commits signed through GPG are allowed'
  end
end
