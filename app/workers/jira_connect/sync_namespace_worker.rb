# frozen_string_literal: true

module JiraConnect
  class SyncNamespaceWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker

    queue_namespace :jira_connect
    feature_category :integrations

    def perform(namespace)
      merge_requests = MergeRequest.for_namespace(namespace).with_jira_issue_keys
      return if merge_requests.count > 30

      merge_requests.each do |mr|
        JiraConnect::SyncMergeRequestWorker.perform_async(mr.id)
      end
    end
  end
end
