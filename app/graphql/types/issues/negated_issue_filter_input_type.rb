# frozen_string_literal: true

module Types
  module Issues
    class NegatedIssueFilterInputType < BaseInputObject
      graphql_name 'NegatedIssueFilterInput'

      argument :iids, [GraphQL::STRING_TYPE],
                required: false,
                description: 'List of IIDs of issues to exclude. For example, `[1, 2]`.'
      argument :label_name, [GraphQL::STRING_TYPE],
                required: false,
                description: 'Labels not applied to this issue.'
      argument :milestone_title, [GraphQL::STRING_TYPE],
                required: false,
                description: 'Milestone not applied to this issue.'
      argument :assignee_usernames, [GraphQL::STRING_TYPE],
                required: false,
                description: 'Usernames of users not assigned to the issue.'
      argument :assignee_id, GraphQL::STRING_TYPE,
                required: false,
                description: 'ID of a user not assigned to the issues.'
      argument :milestone_title_wildcard, ::Types::NegatedMilestoneTitleWildcardEnum,
                required: false,
                description: 'Filter by negated milestone title wildcard.'
    end
  end
end

Types::Issues::NegatedIssueFilterInputType.prepend_mod_with('Types::Issues::NegatedIssueFilterInputType')
