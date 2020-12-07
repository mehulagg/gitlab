# frozen_string_literal: true

module Ci
  module Pipelines
    class SyncJiraWorker
      include ApplicationWorker
      include PipelineBackgroundQueue

      idempotent!

      def perform(deployment_id, sequence_id)
        deployment = Deployment.find_by_id(deployment_id)

        return unless deployment
        return unless Feature.enabled?(:jira_sync_deployments, deployment.project)

        ::JiraConnect::SyncService
          .new(deployment.project)
          .execute(deployments: [deployment], update_sequence_id: sequence_id)
      end
    end
  end
end
