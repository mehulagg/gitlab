# frozen_string_literal: true

module GraphqlTriggers
  def self.issue_updated(issue)
    GitlabSchema.subscriptions.trigger('issueUpdated', { project_path: issue.project.full_path, iid: issue.iid }, issue)
  end
end
