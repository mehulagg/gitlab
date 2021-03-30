# frozen_string_literal: true

module Ci
  class AbortPipelinesService
    # NOTE: Fails pipelines in bulk without running callbacks.
    # Only for pipeline abandonment scenarios (examples: project delete, user block)
    def execute(pipelines, failure_reason)
      pipelines.cancelable.each_batch(of: 100) do |pipeline_batch|
        bulk_fail_for(Ci::Stage, pipeline_batch)
        bulk_fail_for(CommitStatus, pipeline_batch, failure_reason)

        pipeline_batch.update_all(status: :failed, failure_reason: failure_reason, finished_at: Time.current)
      end

      ServiceResponse.success(message: 'Pipelines stopped')
    end

    private

    def bulk_fail_for(klass, pipelines, failure_reason = nil)
      attributes = { status: :failed }
      attributes[:failure_reason] = failure_reason if failure_reason

      klass.in_pipelines(pipelines)
        .cancelable
        .in_batches(of: 150) # rubocop:disable Cop/InBatches
        .update_all(attributes)
    end
  end
end
