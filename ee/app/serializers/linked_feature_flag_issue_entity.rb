# frozen_string_literal: true

class LinkedFeatureFlagIssueEntity < LinkedIssueEntity
  expose :relation_path, override: true do |issue|
    project_feature_flag_issue_path(issuable.project, issuable, issue.link_id)
  end

  expose :link_type do |_issue|
    'relates_to'
  end
end
