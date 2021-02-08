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

    def self.create_link_from_note(note, current_user)
      return unless note.for_issue?

      feature_flag = note.all_references(current_user).feature_flags.first

      return unless feature_flag

      issue = note.noteable

      params = { issuable_references: [issue.to_reference], link_type: 'relates_to' }

      new(feature_flag, current_user, params).execute
    end
  end
end
