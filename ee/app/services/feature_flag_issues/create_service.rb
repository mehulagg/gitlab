# frozen_string_literal: true

module FeatureFlagIssues
  class CreateService < IssuableLinks::CreateService
    def previous_related_issuables
      @related_issues ||= issuable.issues.to_a
    end

    def linkable_issuables(issues)
      Ability.issues_readable_by_user(issues, current_user)
    end

    def relate_issuables(referenced_issue)
      attrs = { feature_flag_id: issuable.id, issue: referenced_issue }
      ::FeatureFlagIssue.create(attrs)
    end
  end
end
