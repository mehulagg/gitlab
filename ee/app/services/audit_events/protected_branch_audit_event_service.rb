# frozen_string_literal: true

module AuditEvents
  class ProtectedBranchAuditEventService < ::AuditEventService
    def initialize(author, protected_branch, action)
      push_access_levels = protected_branch.push_access_levels.map(&:humanize)
      merge_access_levels = protected_branch.merge_access_levels.map(&:humanize)

      super(author, protected_branch.project,
        action => 'protected_branch',
        author_name: author.name,
        target_id: protected_branch.id,
        target_type: protected_branch.class.name,
        target_details: protected_branch.name,
        push_access_levels: push_access_levels,
        merge_access_levels: merge_access_levels
      )
    end
  end
end
