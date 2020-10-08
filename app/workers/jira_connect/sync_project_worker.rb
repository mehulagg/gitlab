# frozen_string_literal: true

module JiraConnect
  class SyncProjectWorker
    include ApplicationWorker

    queue_namespace :jira_connect
    feature_category :integrations
    idempotent!

    MERGE_REQUEST_LIMIT = 400

    def perform(project_id)
      project = Project.find_by_id(project_id)

      return if project.nil?

      JiraConnect::SyncService.new(project).execute(merge_requests: merge_requests_to_sync(project))
    end

    private

    # rubocop: disable CodeReuse/ActiveRecord
    def merge_requests_to_sync(project)
      project.merge_requests.with_jira_issue_keys.with_states(:opened).limit(MERGE_REQUEST_LIMIT).order(id: :desc)
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
