# frozen_string_literal: true

class LinkedIssueFeatureFlagEntity < Grape::Entity
  include RequestAwareEntity

  expose :id, :name, :iid

  expose :active

  expose :path do |link|
    project_feature_flag_path(link.project, link.iid)
  end

  expose :relation_path do |issue|
    project_issue_feature_flag_path(issuable.project, issuable, issue.link_id)
  end

  expose :link_type do |_issue|
    'relates_to'
  end

  def issuable
    request.issuable
  end
end
