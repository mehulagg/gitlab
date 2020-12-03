# frozen_string_literal: true

module Ci
  module Pipelines
    class SyncJiraWorker
      include ApplicationWorker
      include PipelineBackgroundQueue

      idempotent!

      def perform(pipeline_id, sequence_id)
        pipeline = Ci::Pipeline.find_by_id(pipeline_id)

        return unless pipeline
        return unless Feature.enabled?(:jira_sync_builds, pipeline.project)

        ::JiraConnect::SyncService
          .new(pipeline.project)
          .execute(pipelines: [pipeline], update_sequence_id: sequence_id)
      end
    end
  end
end
