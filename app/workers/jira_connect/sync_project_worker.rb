# frozen_string_literal: true

module JiraConnect
  class SyncProjectWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker

    queue_namespace :jira_connect
    feature_category :integrations

    MERGE_REQUEST_LIMIT = 50

    def perform(project_id)
      project = Project.find(project_id)

      return if merge_request_limit_exceeded?(project)

      JiraConnect::SyncService.new(project).execute(merge_requests: merge_requests_to_sync(project))
    end

    private

    def merge_requests_to_sync(project)
      project.merge_requests.with_jira_issue_keys.with_states(:opened)
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def merge_request_limit_exceeded?(project)
      merge_requests_to_sync(project).limit(MERGE_REQUEST_LIMIT + 1).count > MERGE_REQUEST_LIMIT
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
