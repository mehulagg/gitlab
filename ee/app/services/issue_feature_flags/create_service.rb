# frozen_string_literal: true

module IssueFeatureFlags
  class CreateService < IssuableLinks::CreateService
    def previous_related_issuables
      @related_issues ||= issuable.feature_flags.to_a
    end

    def linkable_issuables(feature_flags)
      feature_flags
    end

    def relate_issuables(referenced_feature_flag)
      attrs = { feature_flag: referenced_feature_flags, issue: issuable.id }
      ::FeatureFlagIssue.create(attrs)
    end
  end
end
