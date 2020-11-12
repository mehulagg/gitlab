# frozen_string_literal: true

module Resolvers
  class AuthoredMergeRequestsResolver < UserMergeRequestsResolver
    type ::Types::MergeRequestType.connection_type, null: true
    accept_assignee

    def user_role
      :author
    end
  end
end
