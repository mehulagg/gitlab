# frozen_string_literal: true

module Ci
  class DropPipelineService
    # execute service asynchronously for each cancelable pipeline
    def execute_async_for_all(pipelines, failure_reason, context_user)
      pipelines.cancelable.select(:id).find_in_batches do |pipelines_batch|
        Ci::DropPipelineWorker.bulk_perform_async_with_contexts(
          pipelines_batch,
          arguments_proc: -> (pipeline) { [pipeline.id, failure_reason] },
          context_proc: -> (_) { { user: context_user } }
        )
      end
    end

    def execute(pipeline, failure_reason, retries: 3)
      Gitlab::OptimisticLocking.retry_lock(pipeline.cancelable_statuses, retries, name: 'ci_pipeline_drop_running') do |cancelables|
        cancelables.find_in_batches do |batch|
          preload_associations_for_drop(batch)

          batch.each do |job|
            job.drop(failure_reason)
          end
        end
      end
    end

    private

    def preload_associations_for_drop(builds_batch)
      ActiveRecord::Associations::Preloader.new.preload( # rubocop: disable CodeReuse/ActiveRecord
        builds_batch,
        [:project, :pipeline, :metadata, :deployment, :taggings]
      )
    end
  end
end
