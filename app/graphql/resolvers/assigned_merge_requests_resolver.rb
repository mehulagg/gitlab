# frozen_string_literal: true

module Resolvers
  class AssignedMergeRequestsResolver < UserMergeRequestsResolver
    type ::Types::MergeRequestType.connection_type, null: true
    accept_author

    def user_role
      :assignee
    end
  end
end
