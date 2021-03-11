# frozen_string_literal: true

module Ci
  class AbortPipelinesService
    # Danger: Cancels in bulk without callbacks
    # Only for pipeline abandonment scenarios (examples: project delete, user block)
    def execute(pipelines)
      bulk_abort!(pipelines.cancelable, status: :canceled)

      ServiceResponse.success(message: 'Pipelines canceled')
    end

    private

    # rubocop: disable Cop/InBatches
    def bulk_abort!(pipelines, status:)
      pipelines.select(:id).each_batch do |pipeline_batch|
        Ci::Stage.in_pipelines(pipeline_batch).in_batches.update_all(status: status)
        CommitStatus.in_pipelines(pipeline_batch).in_batches.update_all(status: status)
        pipeline_batch.update_all(status: status)
      end
    end
    # rubocop: enable Cop/InBatches
  end
end
