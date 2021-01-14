# frozen_string_literal: true

module JiraConnect
  class SyncFeatureFlagsWorker
    include ApplicationWorker

    idempotent!
    worker_has_external_dependencies!

    queue_namespace :jira_connect
    feature_category :integrations

    def perform(feature_flag_id, sequence_id)
      feature_flag = ::Operations::FeatureFlag.find_by_id(feature_flag_id)

      return unless feature_flag
      return unless Feature.enabled?(:jira_sync_feature_flags, feature_flag.project)

      ::JiraConnect::SyncService
        .new(feature_flag.project)
        .execute(feature_flags: [feature_flag], update_sequence_id: sequence_id)
    end
  end
end
