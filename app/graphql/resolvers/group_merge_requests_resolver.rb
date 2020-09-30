# frozen_string_literal: true

module Resolvers
  class GroupMergeRequestsResolver < MergeRequestsResolver
    alias_method :group, :synchronized_object

    argument :include_subgroups, GraphQL::BOOLEAN_TYPE,
             required: false,
             default_value: false,
             description: 'Include merge_requests belonging to subgroups.'
    argument :assignee_username, GraphQL::STRING_TYPE,
             required: false,
             description: 'Username of the assignee'
    argument :author_username, GraphQL::STRING_TYPE,
             required: false,
             description: 'Username of the author'

    def project
      nil
    end

    def mr_parent
      group
    end

    def no_results_possible?(args)
      group.nil? || some_argument_is_empty?(args)
    end
  end
end
