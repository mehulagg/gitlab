# frozen_string_literal: true

module Ci
  class DestroyExpiredJobArtifactsService
    include ::Gitlab::ExclusiveLeaseHelpers
    include ::Gitlab::LoopHelpers

    BATCH_SIZE = 100
    LOOP_TIMEOUT = 5.minutes
    LOOP_LIMIT = 1000
    EXCLUSIVE_LOCK_KEY = 'expired_job_artifacts:destroy:lock'
    LOCK_TIMEOUT = 6.minutes

    def initialize
      @removed_artifacts_count = 0
    end

    ##
    # Destroy expired job artifacts on GitLab instance
    #
    # This destroy process cannot run for more than 6 minutes. This is for
    # preventing multiple `ExpireBuildArtifactsWorker` CRON jobs run concurrently,
    # which is scheduled every 7 minutes.
    def execute
      in_lock(EXCLUSIVE_LOCK_KEY, ttl: LOCK_TIMEOUT, retries: 1) do
        destroy_job_artifacts_with_slow_iteration(Time.current)
      end

      @removed_artifacts_count
    end

    private

    def destroy_job_artifacts_with_slow_iteration(start_at)
      Ci::JobArtifact.expired_before(start_at).each_batch(of: BATCH_SIZE, column: :expire_at, order: :desc) do |relation, index|
        artifacts = relation.unlocked.with_destroy_preloads.to_a

        @removed_artifacts_count += parallel_destroy_batch(artifacts)[:size] if artifacts.any?
        break if loop_timeout?(start_at)
        break if index >= LOOP_LIMIT
      end
    end

    def parallel_destroy_batch(artifacts)
      Ci::JobArtifactsParallelDestroyBatchService.new(artifacts).execute
    end

    def loop_timeout?(start_at)
      Time.current > start_at + LOOP_TIMEOUT
    end
  end
end
