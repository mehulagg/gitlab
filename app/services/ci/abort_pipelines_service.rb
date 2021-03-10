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

    def bulk_abort!(pipelines, status:)
      pipelines.each_batch do |pipeline_batch|
        CommitStatus.in_pipelines(pipeline_batch).in_batches.update_all(status: status) # rubocop: disable Cop/InBatches
        pipeline_batch.update_all(status: status)
      end
    end
  end
end
