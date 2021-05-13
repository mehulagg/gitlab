# frozen_string_literal: true

class IssueTrackerData < NamespaceShard
  include Services::DataFields

  attr_encrypted :project_url, encryption_options
  attr_encrypted :issues_url, encryption_options
  attr_encrypted :new_issue_url, encryption_options
end
