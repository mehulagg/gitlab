# frozen_string_literal: true

module JiraConnect
  class SyncProjectWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker

    queue_namespace :jira_connect
    feature_category :integrations

    def perform(project_id)
      project = Project.find(project_id)
      mrs_to_sync = project.merge_requests.with_jira_issue_keys.with_states(:opened)

      return if mrs_to_sync.count > 50

      JiraConnect::SyncService.new(project).execute(merge_requests: mrs_to_sync)
    end
  end
end
